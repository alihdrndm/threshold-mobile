import 'package:flutter/services.dart';

/// The Dart face of the native doorkeeper (UnlockService.kt). Every call
/// tolerates a missing platform — tests and non-Android hosts read as
/// "no doorkeeper", never as a crash.
abstract final class Doorkeeper {
  static const _channel = MethodChannel('threshold/unlock');

  /// The route the unlock chose while the app was already alive.
  static void listen(void Function(String route) onRoute) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'route' && call.arguments is String) {
        onRoute(call.arguments as String);
      }
    });
  }

  /// The route a cold start was born with, consumed exactly once.
  static Future<String?> consumeRoute() async {
    try {
      return await _channel.invokeMethod<String>('consumeRoute');
    } on Object {
      return null;
    }
  }

  static Future<bool> hasOverlayPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasOverlayPermission') ??
          false;
    } on Object {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod<void>('requestOverlayPermission');
    } on Object {
      // The settings screen simply doesn't open where there is none.
    }
  }

  static Future<void> start() async {
    try {
      await _channel.invokeMethod<void>('startDoorkeeper');
    } on Object {
      // No platform, no door.
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stopDoorkeeper');
    } on Object {
      // Already as stopped as it gets.
    }
  }

  static Future<bool> enabled() async {
    try {
      return await _channel.invokeMethod<bool>('doorkeeperEnabled') ?? false;
    } on Object {
      return false;
    }
  }
}
