import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar_sync/presentation/sync_providers.dart';
import '../../tasks/presentation/providers.dart';
import '../data/board_sync_service.dart';

/// True only when Firebase.initializeApp succeeded — overridden in main.
/// Defaults false so widget tests (no Play Services, no google-services
/// resources) never touch the Firebase plugins.
final firebaseReadyProvider = Provider<bool>((_) => false);

final boardSyncProvider = Provider<BoardSyncService>((ref) {
  final service = BoardSyncService(
    ref.watch(databaseProvider),
    ref.watch(googleAuthProvider),
  );
  ref.onDispose(service.stop);
  return service;
});
