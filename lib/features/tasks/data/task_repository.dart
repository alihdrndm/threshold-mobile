import 'dart:convert';

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

  /// Queue a calendar op for the sync pass. The UI never waits on the
  /// network; the outbox drains before every pull, which is what keeps a
  /// queued patch from being dragged back by its own stale remote.
  Future<void> _enqueue(String taskUid, String kind,
          [Map<String, Object?> payload = const {}]) =>
      _db.into(_db.pendingOps).insert(PendingOpsCompanion.insert(
            taskUid: taskUid,
            kind: kind,
            payload: Value(jsonEncode(payload)),
            createdTs: _now,
          ));

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
      final was = quadrantOf(row.urgent, row.important);
      // Entering Schedule books a slot; leaving deletes the lingering
      // event — the desktop's enter/leave lifecycle, queued not awaited.
      if (q == Quadrant.schedule && was != Quadrant.schedule) {
        await _enqueue(uid, 'schedule');
      } else if (q != Quadrant.schedule &&
          was == Quadrant.schedule &&
          row.calendarEventId != null) {
        await _enqueue(uid, 'deleteEvent', {'eventId': row.calendarEventId});
      }
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
          // setSchedule queues the calendar patch too — the advance must
          // reach Google the same way any move does.
          await setSchedule(uid, nextTs);
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

  Future<void> setStatus(String uid, domain.TaskStatus status) async {
    // A task leaving the living board (done/deleted) takes its event with
    // it, the desktop's cleanup rule. Undo re-schedules explicitly.
    if (status == domain.TaskStatus.done ||
        status == domain.TaskStatus.deleted) {
      final row = await _byUid(uid);
      if (row?.calendarEventId != null) {
        await _enqueue(
            uid, 'deleteEvent', {'eventId': row!.calendarEventId});
        await (_db.update(_db.tasks)..where((t) => t.uid.equals(uid)))
            .write(const TasksCompanion(
          calendarEventId: Value(null),
        ));
      }
    }
    await (_db.update(_db.tasks)..where((t) => t.uid.equals(uid)))
        .write(TasksCompanion(
      status: Value(status.name),
      completedTs: status == domain.TaskStatus.done
          ? Value(_nowRfc)
          : const Value(null),
      updatedTs: Value(_now),
    ));
  }

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
  ///
  /// [fromRemote] marks a write that ADOPTS Google's time — it must not
  /// queue a patch back, or two devices echo each other forever.
  Future<void> setSchedule(String uid, int? scheduledTs,
      {bool fromRemote = false}) async {
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
    if (!fromRemote && moved && scheduledTs != null) {
      if (row.calendarEventId != null) {
        await _enqueue(uid, 'patchTime',
            {'eventId': row.calendarEventId, 'start': scheduledTs});
      } else {
        await _enqueue(uid, 'schedule', {'at': scheduledTs});
      }
    }
  }

  /// The pull's adoption write: Google's time wins, silently.
  Future<void> applyRemoteSchedule(String uid, int? ts) =>
      setSchedule(uid, ts, fromRemote: true);

  /// Link an event to a task without queueing anything (insert results,
  /// adoption).
  Future<void> linkEvent(String uid, String eventId, String? htmlLink) =>
      (_db.update(_db.tasks)..where((t) => t.uid.equals(uid)))
          .write(TasksCompanion(
        calendarEventId: Value(eventId),
        calendarHtmlLink: htmlLink == null
            ? const Value.absent()
            : Value(htmlLink),
        updatedTs: Value(_now),
      ));

  /// The pull's cancelled-branch: forget the slot and the link, never
  /// recreate.
  Future<void> clearScheduleFromRemote(String uid) =>
      (_db.update(_db.tasks)..where((t) => t.uid.equals(uid)))
          .write(TasksCompanion(
        scheduledTs: const Value(null),
        calendarEventId: const Value(null),
        calendarHtmlLink: const Value(null),
        remindFiredForTs: const Value(null),
        remindSnoozedUntil: const Value(null),
        updatedTs: Value(_now),
      ));

  Future<domain.Task?> byUid(String uid) async {
    final row = await _byUid(uid);
    return row == null ? null : _toDomain(row);
  }

  /// Adoption: a Google event the user claims as a task. The local row is
  /// born already linked; the caller patches the uid onto the event.
  Future<String> adoptEvent({
    required String title,
    required String eventId,
    required int startTs,
  }) async {
    final uid = _uuid.v4();
    await _db.transaction(() async {
      final max = await (_db.selectOnly(_db.tasks)
            ..addColumns([_db.tasks.sortOrder.max()])
            ..where(_db.tasks.status.equals('open') &
                _db.tasks.urgent.equals(false) &
                _db.tasks.important.equals(true)))
          .getSingle();
      await _db.into(_db.tasks).insert(TasksCompanion.insert(
            uid: uid,
            title: title,
            urgent: const Value(false),
            important: const Value(true),
            sortOrder:
                Value((max.read(_db.tasks.sortOrder.max()) ?? -1) + 1),
            status: const Value('open'),
            createdTs: _nowRfc,
            scheduledTs: Value(startTs),
            calendarEventId: Value(eventId),
            updatedTs: _now,
          ));
    });
    return uid;
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
