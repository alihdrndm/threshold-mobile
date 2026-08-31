import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/google/auth_service.dart';
import '../../../core/google/calendar_client.dart';
import '../../../core/google/client_config.dart';
import '../../tasks/presentation/providers.dart';
import '../data/pull_service.dart';

final googleAuthProvider = Provider<GoogleAuthService>((_) => GoogleAuthService());

final calendarClientProvider = Provider<CalendarClient>((ref) {
  final auth = ref.watch(googleAuthProvider);
  final client = CalendarClient(auth.accessToken);
  ref.onDispose(client.close);
  return client;
});

final pullServiceProvider = Provider<PullService>((ref) => PullService(
      ref.watch(databaseProvider),
      ref.watch(calendarClientProvider),
    ));

/// The connection + sync status surface. One serialized pass at a time;
/// failures land in the status line, never in the way of the board.
final calendarStatusProvider =
    AsyncNotifierProvider<CalendarStatusNotifier, CalendarStatus>(
        CalendarStatusNotifier.new);

class CalendarStatus {
  const CalendarStatus({
    required this.connected,
    this.lastStatus,
    this.thresholdCalendarId,
  });
  final bool connected;
  final String? lastStatus;
  final String? thresholdCalendarId;
}

class CalendarStatusNotifier extends AsyncNotifier<CalendarStatus> {
  bool _syncing = false;

  @override
  Future<CalendarStatus> build() async {
    final repo = ref.read(taskRepositoryProvider);
    final connected = await ref.read(googleAuthProvider).connected;
    return CalendarStatus(
      connected: connected,
      lastStatus: await repo.setting('google_last_sync_status'),
      thresholdCalendarId: await repo.setting('threshold_calendar_id'),
    );
  }

  Future<void> connect() async {
    final repo = ref.read(taskRepositoryProvider);
    var clientId = (await repo.setting('google_client_id'))?.trim() ?? '';
    if (clientId.isEmpty) clientId = kDefaultGoogleClientId;
    await ref.read(googleAuthProvider).connect(clientId);
    await repo.setSetting('google_last_sync_status', 'Connected');
    ref.invalidateSelf();
    // The calendar.app.created spike, on the spot: find or create the
    // hidden board calendar and record the answer.
    try {
      final id = await ref
          .read(calendarClientProvider)
          .findOrCreateThresholdCalendar();
      await repo.setSetting('threshold_calendar_id', id);
    } on Object catch (e) {
      await repo.setSetting(
          'google_last_sync_status', 'Connected; board calendar failed: $e');
    }
    await syncNow();
  }

  Future<void> disconnect() async {
    await ref.read(googleAuthProvider).disconnect();
    await ref
        .read(taskRepositoryProvider)
        .setSetting('google_last_sync_status', 'Disconnected');
    ref.invalidateSelf();
  }

  Future<void> syncNow() async {
    if (_syncing) return;
    _syncing = true;
    final repo = ref.read(taskRepositoryProvider);
    try {
      final status = await ref.read(pullServiceProvider).pullPrimary();
      await repo.setSetting('google_last_sync_status', status);
      await repo.setSetting('google_last_sync_ts',
          '${DateTime.now().millisecondsSinceEpoch ~/ 1000}');
    } on ReconnectNeeded {
      await repo.setSetting(
          'google_last_sync_status', 'Google disconnected - reconnect.');
    } on Object catch (e) {
      await repo.setSetting('google_last_sync_status', '$e');
    } finally {
      _syncing = false;
      ref.invalidateSelf();
    }
  }
}
