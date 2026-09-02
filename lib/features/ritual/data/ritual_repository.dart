import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

/// The check-in grace: ten minutes past the moment the session ended.
/// After that it lapses silently — "a guessed answer scored against a real
/// prediction is worse than no answer at all."
const checkinGraceSecs = 600;

/// The record, counted. Every field is a mirror, never a meter: there is
/// no target here and there will never be a graph.
class OverviewStats {
  const OverviewStats({
    required this.pickupsToday,
    required this.pickupsWeek,
    required this.pickupsAll,
    required this.browsing,
    required this.errands,
    required this.sessionsCommitted,
    required this.sessionsCompleted,
    required this.said,
    required this.kept,
    required this.reclaimedMinutes,
  });

  /// Times the phone came up for no reason at all.
  final int pickupsToday;
  final int pickupsWeek;
  final int pickupsAll;

  /// The honourable exit, admitted.
  final int browsing;

  /// A call, a message — a real errand, and the reason the pickup count
  /// means something.
  final int errands;

  final int sessionsCommitted;
  final int sessionsCompleted;

  /// Answered sessions you predicted you would finish, and how many you did.
  final int said;
  final int kept;

  final int reclaimedMinutes;

  bool get isEmpty =>
      pickupsAll == 0 &&
      browsing == 0 &&
      errands == 0 &&
      sessionsCommitted == 0;
}

/// Quotes, intentions, sessions: the ritual's single writer, mirroring the
/// desktop's invariants — intentions append-only, at most one running
/// session (unique partial index backs it), snapshots not joins.
class RitualRepository {
  RitualRepository(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  int get _now => _clock().millisecondsSinceEpoch ~/ 1000;
  String get _nowRfc => _clock().toIso8601String();

  // ---- the quote reservoir ---------------------------------------------

  Stream<List<QuoteRow>> watchQuotes() =>
      (_db.select(_db.quotes)..orderBy([(q) => OrderingTerm.asc(q.createdTs)]))
          .watch();

  Future<List<QuoteRow>> quotes() => _db.select(_db.quotes).get();

  /// Add a line worth keeping. ≤280 chars, unique text — "the same words
  /// twice is a mistake, not a preference."
  Future<void> addQuote(String text, {String? author}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw ArgumentError('a quote needs its words');
    if (trimmed.length > 280) {
      throw ArgumentError('a quote is at most 280 characters');
    }
    final clean = author?.trim();
    await _db.into(_db.quotes).insert(
          QuotesCompanion.insert(
            body: trimmed,
            author: Value((clean?.isEmpty ?? true) ? null : clean),
            createdTs: _nowRfc,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await _bumpQuotesClock();
  }

  Future<void> removeQuote(String text) async {
    await (_db.delete(_db.quotes)..where((q) => q.body.equals(text))).go();
    await _bumpQuotesClock();
  }

  /// The reservoir's LWW clock for the board channel. A remote apply writes
  /// this directly instead, so its change is never claimed as ours.
  Future<void> _bumpQuotesClock() =>
      _db.into(_db.settingsKV).insertOnConflictUpdate(
          SettingsKVCompanion.insert(
              key: 'quotes_updated_ts', value: '$_now'));

  /// One line for the arrival step; null when the reservoir is empty —
  /// "a line the app chose for you is exactly the borrowed sentiment the
  /// reservoir exists to replace," so an empty reservoir shows nothing.
  Future<QuoteRow?> randomQuote() async {
    final row = await (_db.select(_db.quotes)
          ..orderBy([(q) => OrderingTerm.random()])
          ..limit(1))
        .getSingleOrNull();
    return row;
  }

  // ---- intentions & sessions -------------------------------------------

  /// The commit step: one appended intention, one running session. The
  /// unique running index makes a double-commit fail loudly.
  Future<int> beginSession({
    String? intentionText,
    String? ifThen,
    bool? predictedYes,
    required int durationMin,
    String? taskUid,
    String? taskTitle,
  }) async {
    final minutes = durationMin.clamp(1, 120);
    return _db.transaction(() async {
      final intentionId =
          await _db.into(_db.intentions).insert(IntentionsCompanion.insert(
                ts: _nowRfc,
                body: Value(intentionText),
                ifThen: Value(ifThen),
                predictedYes: Value(switch (predictedYes) {
                  null => null,
                  true => 1,
                  false => 0,
                }),
                durationMin: Value(minutes),
                taskUid: Value(taskUid),
              ));
      final started = _now;
      return _db.into(_db.sessions).insert(SessionsCompanion.insert(
            intentionId: intentionId,
            taskUid: Value(taskUid),
            taskTitle: Value(taskTitle),
            startedTs: started,
            endsTs: started + minutes * 60,
            durationMin: minutes,
            predictedYes: Value(switch (predictedYes) {
              null => null,
              true => 1,
              false => 0,
            }),
          ));
    });
  }

  /// The honourable exit: recorded, never judged.
  Future<void> recordBrowsing() =>
      _db.into(_db.intentions).insert(IntentionsCompanion.insert(
            ts: _nowRfc,
            outcome: const Value('browsing'),
          ));

  /// The phone picked up for no reason at all, admitted and put back down.
  /// The one number this whole loop exists to make visible.
  Future<void> recordPickup() =>
      _db.into(_db.intentions).insert(IntentionsCompanion.insert(
            ts: _nowRfc,
            outcome: const Value('nothing'),
          ));

  /// A real errand — a call, a message. The honest counterpart to a
  /// pickup for nothing: without it, every exit would look purposeless.
  Future<void> recordErrand(String what) =>
      _db.into(_db.intentions).insert(IntentionsCompanion.insert(
            ts: _nowRfc,
            body: Value(what),
            outcome: const Value('errand'),
          ));

  Future<SessionRow?> runningSession() => (_db.select(_db.sessions)
        ..where((s) => s.state.equals('running'))
        ..limit(1))
      .getSingleOrNull();

  Stream<SessionRow?> watchRunning() => (_db.select(_db.sessions)
        ..where((s) => s.state.equals('running'))
        ..limit(1))
      .watchSingleOrNull();

  /// Advance session lifecycle by the clock: a running session past its end
  /// starts awaiting its check-in; one awaiting past the grace lapses
  /// silently. Returns the session now awaiting an answer, if any.
  Future<SessionRow?> settle() async {
    final now = _now;
    // running & past ends → awaiting_checkin (ended at its own end time).
    await (_db.update(_db.sessions)
          ..where((s) =>
              s.state.equals('running') & s.endsTs.isSmallerOrEqualValue(now)))
        .write(SessionsCompanion(
      state: const Value('awaiting_checkin'),
      endedTs: Value(now),
    ));
    // awaiting past grace → lapsed, silently.
    await _db.customStatement(
      "UPDATE sessions SET state = 'lapsed' "
      "WHERE state = 'awaiting_checkin' "
      'AND COALESCE(ended_ts, ends_ts) + $checkinGraceSecs < $now',
    );
    return (_db.select(_db.sessions)
          ..where((s) => s.state.equals('awaiting_checkin'))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<SessionRow?> byId(int id) => (_db.select(_db.sessions)
        ..where((s) => s.id.equals(id)))
      .getSingleOrNull();

  /// End the running session before its time: it goes straight to its
  /// check-in — ending early is an answered life, not an abandoned one.
  Future<void> endEarly(int id) => (_db.update(_db.sessions)
        ..where((s) => s.id.equals(id) & s.state.equals('running')))
      .write(SessionsCompanion(
        state: const Value('awaiting_checkin'),
        endedTs: Value(_now),
      ));

  /// The check-in's verdict. [state] is completed | partly | missed.
  Future<void> answer(int id, String state, {bool taskDone = false}) async {
    assert(state == 'completed' || state == 'partly' || state == 'missed');
    await (_db.update(_db.sessions)..where((s) => s.id.equals(id)))
        .write(SessionsCompanion(
      state: Value(state),
      answeredTs: Value(_now),
      taskDone: Value(taskDone ? 1 : 0),
    ));
  }

  /// What the record says, counted. Aggregates in SQL rather than pulled
  /// as rows: a phone answered fifty times a day fills this table fast.
  Future<OverviewStats> stats() async {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    final week = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6))
        .toIso8601String();

    Future<int> count(String outcome, {String? since}) async {
      final row = await _db.customSelect(
        'SELECT COUNT(*) AS n FROM intentions WHERE outcome = ?1'
        '${since == null ? '' : ' AND ts >= ?2'}',
        variables: [
          Variable.withString(outcome),
          if (since != null) Variable.withString(since),
        ],
      ).getSingle();
      return row.read<int>('n');
    }

    // Sessions are counted from their own state, never from the
    // intention's outcome: beginSession deliberately leaves outcome null
    // (an intention records what you SAID, a session how it went), so
    // reading 'completed' off intentions here would always find zero.
    final sessionRows = await _db.select(_db.sessions).get();
    final committed = sessionRows.length;
    final completed =
        sessionRows.where((s) => s.state == 'completed').length;

    // The desktop's calibrate(), verbatim in spirit: only answered
    // sessions where you predicted yes, and 'partly' is never promoted to
    // kept — the point is whether your predictions can be trusted, not
    // whether they look good.
    final said = sessionRows.where((s) =>
        s.predictedYes == 1 &&
        (s.state == 'completed' ||
            s.state == 'partly' ||
            s.state == 'missed'));
    final kept = said.where((s) => s.state == 'completed').length;

    // Elapsed, clamped to what was committed: a session answered an hour
    // late did not run for an extra hour.
    var reclaimed = 0;
    for (final s in sessionRows) {
      if (s.state != 'completed' && s.state != 'partly') continue;
      final ended = s.endedTs;
      if (ended == null) continue;
      final elapsed = ended - s.startedTs;
      final committedSecs = s.durationMin * 60;
      reclaimed += elapsed.clamp(0, committedSecs);
    }

    return OverviewStats(
      pickupsToday: await count('nothing', since: today),
      pickupsWeek: await count('nothing', since: week),
      pickupsAll: await count('nothing'),
      browsing: await count('browsing'),
      errands: await count('errand'),
      sessionsCommitted: committed,
      sessionsCompleted: completed,
      said: said.length,
      kept: kept,
      reclaimedMinutes: reclaimed ~/ 60,
    );
  }

  /// Suggestions for the intention step: the top Do First tasks (carrying
  /// their uid, so picking one links the session), then distinct recent
  /// intention texts — shown, never imposed.
  Future<List<({String text, String? taskUid})>> intentionSuggestions() async {
    final doFirst = await (_db.select(_db.tasks)
          ..where((t) =>
              t.status.equals('open') &
              t.urgent.equals(true) &
              t.important.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])
          ..limit(3))
        .get();
    final recent = await _db
        .customSelect(
          'SELECT DISTINCT text FROM intentions '
          'WHERE text IS NOT NULL ORDER BY id DESC LIMIT 5',
        )
        .get();
    final out = <({String text, String? taskUid})>[];
    for (final t in doFirst) {
      out.add((text: t.title, taskUid: t.uid));
    }
    for (final r in recent) {
      final text = r.read<String>('text');
      if (!out.any((s) => s.text == text)) {
        out.add((text: text, taskUid: null));
      }
    }
    return out.take(6).toList();
  }
}
