import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/board_sync/presentation/board_sync_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Channel 2 rides on Firebase; the board must not care if it's absent
  // (tests, a build without google-services.json, a broken install).
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } on Object {
    // Board and channel 1 work untouched; channel 2 just stays off.
  }
  runApp(ProviderScope(
    overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
    child: const ThresholdApp(),
  ));
}
