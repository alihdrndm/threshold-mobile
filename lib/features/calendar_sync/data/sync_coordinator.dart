import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/google/calendar_client.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/slot.dart';

/// One serialized sync pass, in the desktop-proven order:
/// roll-forward → drain the outbox → pull → bookkeeping. Draining before
/// pulling is what keeps a queued patch from being dragged back by its own
/// stale remote copy — the mobile answer to the desktop's Google-first rule.
class SyncCoordinator {
  SyncCoordinator(this._db, this._client, this._repo);

  final AppDatabase _db;
  final CalendarClient _client;
  final TaskRepository _repo;

  bool _running = false;

  Future<String> pass() async {
    if (_running) return 'Already syncing';
    _running = true;
    try {
      await _repo.rollPastRepeats(); // queues patches via setSchedule
      await _drainOutbox();
      await _pullPrimary();
      return 'Synced';
    } finally {
      _running = false;
    }
  }

  Future<void> _drainOutbox() async {
    final ops = await (_db.select(_db.pendingOps)
          ..where((o) => o.attempts.isSmallerThanValue(3))
          ..orderBy([(o) => OrderingTerm.asc(o.id)]))
        .get();
    for (final op in ops) {
      try {
        await _apply(op);
        await (_db.delete(_db.pendingOps)..where((o) => o.id.equals(op.id)))
            .go();
      } on Object catch (e) {
        await (_db.update(_db.pendingOps)..where((o) => o.id.equals(op.id)))
            .write(PendingOpsCompanion(
          attempts: Value(op.attempts + 1),
          lastError: Value('$e'),
        ));
        // Never block the queue behind one failure.
      }
    }
  }

  Future<void> _apply(PendingOpRow op) async {
    final payload = jsonDecode(op.payload) as Map<String, dynamic>;
    switch (op.kind) {
      case 'schedule':
        final task = await _repo.byUid(op.taskUid);
        // The task may have moved on — left Schedule, been deleted —
        // between queueing and draining. Stale intent is dropped, not
        // replayed.
        if (task == null || !task.isOpen || !task.inSchedule) return;
        // Duplicate guard: two writers deciding "this task needs an event"
        // must converge on one.
        final existing =
            await _client.findEventByUid('primary', op.taskUid);
        final at = payload['at'] as int? ?? task.scheduledTs;
        DateTime start;
        if (at != null) {
          start = DateTime.fromMillisecondsSinceEpoch(at * 1000);
        } else {
          final hours =
              WorkingHours.fromSettings(await _allSettings());
          final busy = await _client.freeBusy(
              DateTime.now(), DateTime.now().add(const Duration(days: 14)));
          final slot = nextFreeSlot(DateTime.now(), hours, busy);
          if (slot == null) {
            throw StateError(
                'no free slot in the next two weeks - widen your working hours');
          }
          start = slot;
        }
        if (existing != null) {
          await _client.patchEventTime('primary', existing, start);
          await _repo.linkEvent(op.taskUid, existing, null);
        } else {
          final created = await _client.insertEvent(
            calendarId: 'primary',
            title: task.title,
            start: start,
            taskUid: op.taskUid,
            legacyDesktopId: task.legacyDesktopId,
          );
          await _repo.linkEvent(op.taskUid, created.id, created.htmlLink);
        }
        await _repo.applyRemoteSchedule(
            op.taskUid, start.millisecondsSinceEpoch ~/ 1000);
      case 'patchTime':
        final eventId = payload['eventId'] as String?;
        final start = payload['start'] as int?;
        if (eventId == null || start == null) return;
        await _client.patchEventTime('primary', eventId,
            DateTime.fromMillisecondsSinceEpoch(start * 1000));
      case 'deleteEvent':
        final eventId = payload['eventId'] as String?;
        if (eventId == null) return;
        await _client.deleteEvent('primary', eventId);
    }
  }

  Future<void> _pullPrimary() async {
    const calendarId = 'primary';
    final state = await (_db.select(_db.syncState)
          ..where((s) => s.calendarId.equals(calendarId)))
        .getSingleOrNull();

    ({List<GEvent> items, String? nextSyncToken}) result;
    try {
      result = await _client.listEvents(
        calendarId,
        syncToken: state?.syncToken,
        timeMin: state?.syncToken == null
            ? DateTime.now().subtract(const Duration(days: 90))
            : null,
      );
    } on SyncTokenExpired {
      result = await _client.listEvents(
        calendarId,
        timeMin: DateTime.now().subtract(const Duration(days: 90)),
      );
    }

    for (final e in result.items) {
      if (e.id.isEmpty) continue;
      // Reconcile our own linked tasks — the desktop's branches, verbatim.
      final task = e.thresholdTaskUid != null
          ? await _repo.byUid(e.thresholdTaskUid!)
          : null;
      final linked = task != null && task.calendarEventId == e.id;
      if (linked) {
        if (e.cancelled) {
          // Cancelled in Google → clear the link, never recreate.
          await _repo.clearScheduleFromRemote(task.uid);
        } else if (task.isOpen && task.inSchedule) {
          // Moved in Google → Google's time wins, silently.
          if (e.startTs != null && e.startTs != task.scheduledTs) {
            await _repo.applyRemoteSchedule(task.uid, e.startTs);
          }
        } else {
          // The task left Schedule while the event lingers: clean up.
          await _repo.clearScheduleFromRemote(task.uid);
          try {
            await _client.deleteEvent(calendarId, e.id);
          } on Object {
            // Next pass retries.
          }
        }
      }
      // The read model for the week view, threshold or foreign alike.
      if (e.cancelled) {
        await (_db.delete(_db.googleEventMap)
              ..where((g) => g.eventId.equals(e.id)))
            .go();
      } else {
        await _db.into(_db.googleEventMap).insertOnConflictUpdate(
              GoogleEventMapCompanion.insert(
                eventId: e.id,
                calendarId: calendarId,
                summary: Value(e.summary),
                startTs: Value(e.startTs),
                endTs: Value(e.endTs),
                isAllDay: Value(e.isAllDay),
                updated: Value(e.updated),
                isThreshold: Value(e.isThreshold),
                status: Value(e.status),
                eventType: Value(e.eventType),
              ),
            );
      }
    }
    if (result.nextSyncToken != null) {
      await _db.into(_db.syncState).insertOnConflictUpdate(
            SyncStateCompanion.insert(
              calendarId: calendarId,
              syncToken: Value(result.nextSyncToken),
              lastSyncTs:
                  Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
              lastStatus: const Value('Synced'),
            ),
          );
    }
  }

  /// Adopt a Google event as a Threshold task: local row first, then the
  /// event is claimed by patching the uid on — never delete+recreate.
  Future<String> adopt(GoogleEventRow event) async {
    final uid = await _repo.adoptEvent(
      title: event.summary.isEmpty ? '(untitled)' : event.summary,
      eventId: event.eventId,
      startTs: event.startTs ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    await _client.claimEvent(event.calendarId, event.eventId, uid);
    await (_db.update(_db.googleEventMap)
          ..where((g) => g.eventId.equals(event.eventId)))
        .write(GoogleEventMapCompanion(
      isThreshold: const Value(true),
      adoptedTaskUid: Value(uid),
    ));
    return uid;
  }

  Future<Map<String, String>> _allSettings() async {
    final rows = await _db.select(_db.settingsKV).get();
    return {for (final r in rows) r.key: r.value};
  }
}
