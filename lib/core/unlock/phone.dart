import 'package:flutter/services.dart';

/// The phone itself, as far as the ritual needs it: the power to put the
/// screen back to sleep, and the two errands worth walking out for.
///
/// Same contract as [Doorkeeper]: every call tolerates a missing platform,
/// so tests and non-Android hosts read as "cannot", never as a crash. The
/// launches answer with a bool so a missing app is something the UI can
/// say out loud rather than a tap that does nothing.
abstract final class Phone {
  static const _channel = MethodChannel('threshold/unlock');

  static Future<bool> _ask(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on Object {
      return false;
    }
  }

  /// Is Threshold allowed to lock the screen (device admin active)?
  static Future<bool> canLock() => _ask('canLock');

  /// Open the system's grant screen for the force-lock policy.
  static Future<bool> requestLock() => _ask('requestLock');

  /// Put the screen to sleep. False when the grant is missing — the app
  /// goes home instead, which is honest rather than silent.
  static Future<bool> lockNow() => _ask('lockNow');

  /// Hand the power back. Also removes device admin's uninstall friction.
  static Future<void> revokeLock() async {
    try {
      await _channel.invokeMethod<void>('revokeLock');
    } on Object {
      // Nothing to hand back.
    }
  }

  static Future<bool> openDialer() => _ask('openDialer');

  static Future<bool> openWhatsApp() => _ask('openWhatsApp');
}
