import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'client_config.dart';

/// Google auth through Play Services — the native account dialog, no
/// browser tab, no redirect scheme, no process-death window (all three
/// failed live on OneUI with the AppAuth route). Play Services mints and
/// refreshes access tokens itself; there is no refresh token to store.
///
/// The Android OAuth client (package + SHA-1) the user registered is what
/// authorizes this app; the id never needs to be passed on Android.
///
/// Sign-out is local only — never a server-side revoke, which would reach
/// the desktop's grant too.
class GoogleAuthService {
  GoogleAuthService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const scopes = [
    'https://www.googleapis.com/auth/calendar.events',
    'https://www.googleapis.com/auth/calendar.freebusy',
    'https://www.googleapis.com/auth/calendar.app.created',
  ];

  static const _connectedKey = 'google_connected';
  bool _initialized = false;
  GoogleSignInAccount? _account;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: kServerClientId);
    _initialized = true;
  }

  Future<void> connect(String _) async {
    await _ensureInitialized();
    final account =
        await GoogleSignIn.instance.authenticate(scopeHint: scopes);
    // Surface the scope grant now, not at the first sync.
    await account.authorizationClient.authorizeScopes(scopes);
    _account = account;
    await _storage.write(key: _connectedKey, value: '1');
  }

  /// A live access token, silently refreshed by Play Services. Null when
  /// never connected; [ReconnectNeeded] when the grant is gone.
  Future<String?> accessToken() async {
    if (await _storage.read(key: _connectedKey) != '1') return null;
    await _ensureInitialized();
    try {
      final account = _account ??=
          await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (account == null) throw const ReconnectNeeded();
      final auth =
          await account.authorizationClient.authorizationForScopes(scopes);
      if (auth == null) throw const ReconnectNeeded();
      return auth.accessToken;
    } on ReconnectNeeded {
      rethrow;
    } on Object {
      throw const ReconnectNeeded();
    }
  }

  /// The Google ID token for the signed-in account — the bridge into
  /// Firebase Auth (channel 2). Null when never connected or Play
  /// Services can't produce one silently.
  Future<String?> idToken() async {
    if (await _storage.read(key: _connectedKey) != '1') return null;
    await _ensureInitialized();
    try {
      final account = _account ??=
          await GoogleSignIn.instance.attemptLightweightAuthentication();
      return account?.authentication.idToken;
    } on Object {
      return null;
    }
  }

  /// Forget the cached account so the next token fetch starts fresh -
  /// the 401-retry path. Local only; the grant is untouched.
  Future<void> dropSession() async {
    _account = null;
  }

  Future<bool> get connected async {
    try {
      return await _storage.read(key: _connectedKey) == '1';
    } on Object {
      // No keystore (tests, first boot on a broken profile) reads as
      // "not connected", never as a crash.
      return false;
    }
  }

  Future<void> disconnect() async {
    await _storage.delete(key: _connectedKey);
    _account = null;
    try {
      await GoogleSignIn.instance.signOut(); // local only, never disconnect()
    } on Object {
      // Signed out is signed out.
    }
  }
}

class ReconnectNeeded implements Exception {
  const ReconnectNeeded();
  @override
  String toString() => 'Google disconnected - reconnect in Settings.';
}
