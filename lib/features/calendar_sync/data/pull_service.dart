import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/google/calendar_client.dart';

/// M2's read-only pull: list the primary calendar into the local read
/// model with the desktop's cadence discipline — per-device syncToken,
/// full pageToken looping, 410 → drop the token and re-list with a
/// generous window (90 days, not the desktop's too-tight 1 day).
class PullService {
  PullService(this._db, this._client);

  final AppDatabase _db;
  final CalendarClient _client;

  Future<String> pullPrimary() async {
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

    await _db.transaction(() async {
      for (final e in result.items) {
        if (e.id.isEmpty) continue;
        if (e.cancelled) {
          await (_db.delete(_db.googleEventMap)
                ..where((g) => g.eventId.equals(e.id)))
              .go();
          continue;
        }
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
      // The token from the final page only; a pass that yielded none keeps
      // the previous cursor rather than clearing it.
      if (result.nextSyncToken != null) {
        await _db.into(_db.syncState).insertOnConflictUpdate(
              SyncStateCompanion.insert(
                calendarId: calendarId,
                syncToken: Value(result.nextSyncToken),
                lastSyncTs: Value(
                    DateTime.now().millisecondsSinceEpoch ~/ 1000),
                lastStatus: const Value('Synced'),
              ),
            );
      }
    });
    return 'Synced';
  }
}
