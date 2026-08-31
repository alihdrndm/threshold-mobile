import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../domain/quadrant.dart';
import '../domain/repeat.dart';
import '../domain/task.dart' as domain;

/// The board's single writer. Every invariant the desktop enforces in
/// `db/tasks.rs` lives here, so no caller can quietly bypass one:
/// quadrant transitions clear the repeat unless the destination is
/// Schedule; leaving the calendar wipes the reminder bookkeeping; a real
/// slot move clears a snooze but a confirming write keeps it.
class TaskRepository {
  TaskRepository(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  final _uuid = const Uuid();

  int get _now => _clock().millisecondsSinceEpoch ~/ 1000;
  String get _nowRfc => _clock().toIso8601String();

  Stream<List<domain.Task>> watchAll() =>
      (_db.select(_db.tasks)
            ..where((t) => t.status.isNotValue('deleted'))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.id)]))
          .watch()
          .map((rows) => rows.map(_toDomain).toList());

  Stream<List<domain.Area>> watchAreas() =>
      (_db.select(_db.areas)..orderBy([(a) => OrderingTerm.asc(a.sortOrder)]))
          .watch()
          .map((rows) => [
                for (final r in rows)
                  domain.Area(
                    uid: r.uid,
                    name: r.name,
                    sortOrder: r.sortOrder,
                    updatedTs: r.updatedTs,
                  ),
              ]);

  /// New tasks join the END of the Inbox — "a fresh 0 would cut into the
  /// middle of an arranged list."
  Future<String> add(String title, {String? areaUid, String? note}) async {
    final uid = _uuid.v4();
    await _db.transaction(() async {
      final max = await (_db.selectOnly(_db.tasks)
            ..addColumns([_db.tasks.sortOrder.max()])
            ..where(_db.tasks.status.equals('open') &
                _db.tasks.urgent.isNull() &
                _db.tasks.important.isNull()))
          .getSingle();
      final next = (max.read(_db.tasks.sortOrder.max()) ?? -1) + 1;
      await _db.into(_db.tasks).insert(TasksCompanion.insert(
            uid: uid,
            title: title,
            note: Value(note),
            areaUid: Value(areaUid),
            sortOrder: Value(next),
            createdTs: _nowRfc,
            updatedTs: _now,
          ));
    });
    return uid;
  }

  /// Move to a quadrant, appending to its end (desktop's
  /// `append_to_quadrant` — for callers "not looking at the board").
  /// The repeat survives only when the destination is Schedule: "a task
  /// dragged to Do First should not quietly come back next Tuesday."
  Future<void> moveToQuadrant(String uid, Quadrant q) async {
    final (urgent, important) = flagsOf(q);
    await _db.transaction(() async {
      final row = await _byUid(uid);
      if (row == null) return;
      final max = await (_db.selectOnly(_db.tasks)
            ..addColumns([_db.tasks.sortOrder.max()])
            ..where(_db.tasks.status.equals('open') &
                _flagEq(_db.tasks.urgent, urgent) &
                _flagEq(_db.tasks.important, important) &
                _db.tasks.uid.isNotValue(uid)))
          .getSingle();
      final next = (max.read(_db.tasks.sortOrder.max()) ?? -1) + 1;
      final keepsRepeat = q == Quadrant.schedule;
      await (_db.update(_db.tasks)..where((t) => t.uid.equals(uid))).write(
        TasksCompanion(
          urgent: Value(urgent),
          important: Value(important),
          sortOrder: Value(next),
          repeatDays:
              keepsRepeat ? const Value.absent() : const Value(null),
          // Leaving Schedule forgets the slot and its reminder bookkeeping.
          scheduledTs:
              keepsRepeat ? const Value.absent() : const Value(null),
          calendarEventId:
              keepsRepeat ? const Value.absent() : const Value(null),
          calendarHtmlLink:
              keepsRepeat ? const Value.absent() : const Value(null),
          remindFiredForTs:
              keepsRepeat ? const Value.absent() : const Value(null),
          remindSnoozedUntil:
              keepsRepeat ? const Value.absent() : const Value(null),
          updatedTs: Value(_now),
        ),
      );
    });
  }

  /// Reorder within a zone: write each uid its index, "scoped to exactly
  /// the ids given" so renumbering one quadrant cannot scramble another.
  Future<void> reorder(List<String> uids) => _db.transaction(() async {
        for (final (i, uid) in uids.indexed) {
          await (_db.update(_db.tasks)..where((t) => t.uid.equals(uid)))
              .write(TasksCompanion(sortOrder: Value(i), updatedTs: Value(_now)));
        }
      });

  /// Completing decides advance-vs-done inside one transaction "so the
  /// checkbox and the check-in cannot disagree about what 'done' means."
  /// Returns the advanced-to slot when the task moved instead of finishing.
  Future<int?> complete(String uid) async {
    return _db.transaction(() async {
      final row = await _byUid(uid);
      if (row == null) return null;
      final t = _toDomain(row);
      final advances = t.isOpen && t.inSchedule && t.repeating;
      if (advances) {
        final anchor = t.scheduledTs != null
            ? DateTime.fromMillisecondsSinceEpoch(t.scheduledTs! * 1000)
            : _clock();
        // "Advance past the held slot, never onto it: completing Sunday
        // evening for Monday's slot lands after Monday."
        final after =
            anchor.isAfter(_clock()) ? anchor : _clock();
        final next = nextOccurrence(
            after, dayMask(t.repeatDays!), anchor.hour, anchor.minute);
        if (next != null) {
          final nextTs = next.millisecondsSinceEpoch ~/ 1000;
          await (_db.update(_db.tasks)..where((r) => r.uid.equals(uid)))
              .write(TasksCompanion(
            scheduledTs: Value(nextTs),
            updatedTs: Value(_now),
          ));
          return nextTs;
        }
      }
      await (_db.update(_db.tasks)..where((r) => r.uid.equals(uid)))
          .write(TasksCompanion(
        status: const Value('done'),
        completedTs: Value(_nowRfc),
        updatedTs: Value(_now),
      ));
      return null;
    });
  }

  Future<void> setStatus(String uid, domain.TaskStatus status) =>
      (_db.update(_db.tasks)..where((t) => t.uid.equals(uid)))
          .write(TasksCompanion(
        status: Value(status.name),
        completedTs: status == domain.TaskStatus.done
            ? Value(_nowRfc)
            : const Value(null),
        updatedTs: Value(_now),
      ));

  Future<void> setTitleAndNote(String uid, String title, String? note) =>
      (_db.update(_db.tasks)..where((t) => t.uid.equals(uid)))
          .write(TasksCompanion(
        title: Value(title),
        note: Value(note),
        updatedTs: Value(_now),
      ));

  Future<void> setArea(String uid, String? areaUid) =>
      (_db.update(_db.tasks)..where((t) => t.uid.equals(uid)))
          .write(TasksCompanion(
        areaUid: Value(areaUid),
        updatedTs: Value(_now),
      ));

  Future<void> setRepeat(String uid, String? days) =>
      (_db.update(_db.tasks)..where((t) => t.uid.equals(uid)))
          .write(TasksCompanion(
        repeatDays: Value(days == null ? null : normalizeDays(days)),
        updatedTs: Value(_now),
      ));

  /// Record the slot. A snooze survives only a write that confirms the same
  /// time; the fired marker is left alone — "keyed to the old slot, it goes
  /// stale by itself and the new slot re-arms with no clearing code."
  Future<void> setSchedule(String uid, int? scheduledTs) async {
    final row = await _byUid(uid);
    if (row == null) return;
    final moved = row.scheduledTs != scheduledTs;
    await (_db.update(_db.tasks)..where((t) => t.uid.equals(uid)))
        .write(TasksCompanion(
      scheduledTs: Value(scheduledTs),
      remindSnoozedUntil:
          moved ? const Value(null) : const Value.absent(),
      updatedTs: Value(_now),
    ));
  }

  /// Missed repeats come forward at the day boundary — same math as the
  /// desktop, so both devices roll the same repeat to the same instant.
  Future<int> rollPastRepeats() async {
    final today = _clock();
    final midnight =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch ~/
            1000;
    final stale = await (_db.select(_db.tasks)
          ..where((t) =>
              t.status.equals('open') &
              t.urgent.equals(false) &
              t.important.equals(true) &
              t.repeatDays.isNotNull() &
              t.scheduledTs.isSmallerThanValue(midnight)))
        .get();
    var rolled = 0;
    for (final row in stale) {
      final anchor =
          DateTime.fromMillisecondsSinceEpoch(row.scheduledTs! * 1000);
      final next = rollForward(anchor, dayMask(row.repeatDays!), today);
      if (next == null) continue;
      await setSchedule(row.uid, next.millisecondsSinceEpoch ~/ 1000);
      rolled++;
    }
    return rolled;
  }

  // Areas ------------------------------------------------------------------

  Future<String> addArea(String name) async {
    final uid = _uuid.v4();
    await _db.transaction(() async {
      final existing = await _db.select(_db.areas).get();
      if (existing.length >= 8) {
        throw StateError('Eight at most: past that they stop being areas.');
      }
      if (existing.any((a) => a.name.toLowerCase() == name.toLowerCase())) {
        throw StateError('There is already an area called $name.');
      }
      await _db.into(_db.areas).insert(AreasCompanion.insert(
            uid: uid,
            name: name,
            sortOrder: existing.length,
            updatedTs: _now,
          ));
    });
    return uid;
  }

  Future<void> renameArea(String uid, String name) =>
      (_db.update(_db.areas)..where((a) => a.uid.equals(uid)))
          .write(AreasCompanion(name: Value(name), updatedTs: Value(_now)));

  /// "Deleting a label must never delete the things it labelled." Returns
  /// the uids of tasks that wore it, for the undo notice.
  Future<List<String>> removeArea(String uid) => _db.transaction(() async {
        final wearing = await (_db.select(_db.tasks)
              ..where((t) => t.areaUid.equals(uid)))
            .get();
        await (_db.update(_db.tasks)..where((t) => t.areaUid.equals(uid)))
            .write(TasksCompanion(
          areaUid: const Value(null),
          updatedTs: Value(_now),
        ));
        await (_db.delete(_db.areas)..where((a) => a.uid.equals(uid))).go();
        return [for (final t in wearing) t.uid];
      });

  // Settings ---------------------------------------------------------------

  Future<String?> setting(String key) async {
    final row = await (_db.select(_db.settingsKV)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) =>
      _db.into(_db.settingsKV).insertOnConflictUpdate(
          SettingsKVCompanion.insert(key: key, value: value));

  Stream<Map<String, String>> watchSettings() =>
      _db.select(_db.settingsKV).watch().map(
          (rows) => {for (final r in rows) r.key: r.value});

  // -------------------------------------------------------------------------

  Future<TaskRow?> _byUid(String uid) =>
      (_db.select(_db.tasks)..where((t) => t.uid.equals(uid)))
          .getSingleOrNull();

  Expression<bool> _flagEq(Column<bool> col, bool? v) =>
      v == null ? col.isNull() : col.equals(v);

  domain.Task _toDomain(TaskRow r) => domain.Task(
        uid: r.uid,
        title: r.title,
        note: r.note,
        areaUid: r.areaUid,
        urgent: r.urgent,
        important: r.important,
        sortOrder: r.sortOrder,
        status: domain.TaskStatus.values.byName(r.status),
        createdTs: r.createdTs,
        completedTs: r.completedTs,
        scheduledTs: r.scheduledTs,
        calendarEventId: r.calendarEventId,
        calendarHtmlLink: r.calendarHtmlLink,
        repeatDays: r.repeatDays,
        remindFiredForTs: r.remindFiredForTs,
        remindSnoozedUntil: r.remindSnoozedUntil,
        boardEventId: r.boardEventId,
        legacyDesktopId: r.legacyDesktopId,
        updatedTs: r.updatedTs,
      );
}
