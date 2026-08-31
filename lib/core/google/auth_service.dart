import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Google OAuth for an installed Android app: the user's OWN client id (no
/// secret exists for Android clients), custom-scheme redirect, PKCE via
/// AppAuth, tokens in the platform keystore.
///
/// Scopes: events read/write, freeBusy, and the granular app-created-
/// calendars scope that powers the hidden "Threshold" board calendar.
///
/// Sign-out wipes local tokens and NEVER calls /revoke — revocation is
/// per-user-per-client-family and can kill the desktop's grant too.
class GoogleAuthService {
  GoogleAuthService({FlutterAppAuth? appAuth, FlutterSecureStorage? storage})
      : _appAuth = appAuth ?? const FlutterAppAuth(),
        _storage = storage ?? const FlutterSecureStorage();

  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _storage;

  static const scopes = [
    'https://www.googleapis.com/auth/calendar.events',
    'https://www.googleapis.com/auth/calendar.freebusy',
    'https://www.googleapis.com/auth/calendar.app.created',
  ];

  static const _tokenKey = 'google_tokens';

  static const _config = AuthorizationServiceConfiguration(
    authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
    tokenEndpoint: 'https://oauth2.googleapis.com/token',
  );

  /// Google's required redirect for Android clients:
  /// `com.googleusercontent.apps.[reversed-client-id]:/oauth2redirect`
  static String redirectFor(String clientId) {
    final head = clientId.split('.apps.googleusercontent.com').first;
    return 'com.googleusercontent.apps.$head:/oauth2redirect';
  }

  Future<void> connect(String clientId) async {
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        redirectFor(clientId),
        serviceConfiguration: _config,
        scopes: scopes,
        // A refresh token arrives on consent; ask for it explicitly so a
        // reconnect never silently returns access-only.
        promptValues: ['consent'],
        additionalParameters: const {'access_type': 'offline'},
      ),
    );
    final refresh = result.refreshToken;
    if (refresh == null) {
      throw StateError(
          'Google returned no refresh token - remove Threshold from your '
          'Google account’s connected apps and try again.');
    }
    await _save(_Tokens(
      access: result.accessToken!,
      refresh: refresh,
      expiresAt: _expiry(result.accessTokenExpirationDateTime),
      clientId: clientId,
    ));
  }

  /// A valid access token, refreshing when needed. Returns null when not
  /// connected. Throws [ReconnectNeeded] on invalid_grant — the visible
  /// "reconnect in Settings" state; the outbox keeps queueing behind it.
  Future<String?> accessToken() async {
    final t = await _load();
    if (t == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (t.expiresAt > now) return t.access;
    try {
      final result = await _appAuth.token(TokenRequest(
        t.clientId,
        redirectFor(t.clientId),
        serviceConfiguration: _config,
        refreshToken: t.refresh,
        scopes: scopes,
      ));
      final next = _Tokens(
        access: result.accessToken!,
        // Google usually omits the refresh token on refresh; keep ours.
        refresh: result.refreshToken ?? t.refresh,
        expiresAt: _expiry(result.accessTokenExpirationDateTime),
        clientId: t.clientId,
      );
      await _save(next);
      return next.access;
    } on Object catch (e) {
      if ('$e'.contains('invalid_grant')) {
        await disconnect();
        throw const ReconnectNeeded();
      }
      rethrow;
    }
  }

  Future<bool> get connected async => await _load() != null;

  Future<void> disconnect() => _storage.delete(key: _tokenKey);

  int _expiry(DateTime? at) =>
      ((at ?? DateTime.now().add(const Duration(minutes: 50)))
              .millisecondsSinceEpoch ~/
          1000) -
      60; // the desktop's 60s skew, baked in at save time

  Future<void> _save(_Tokens t) => _storage.write(
        key: _tokenKey,
        value: jsonEncode({
          'access': t.access,
          'refresh': t.refresh,
          'expiresAt': t.expiresAt,
          'clientId': t.clientId,
        }),
      );

  Future<_Tokens?> _load() async {
    final raw = await _storage.read(key: _tokenKey);
    if (raw == null || raw.isEmpty) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return _Tokens(
      access: map['access'] as String,
      refresh: map['refresh'] as String,
      expiresAt: map['expiresAt'] as int,
      clientId: map['clientId'] as String,
    );
  }
}

class ReconnectNeeded implements Exception {
  const ReconnectNeeded();
  @override
  String toString() => 'Google disconnected - reconnect in Settings.';
}

class _Tokens {
  const _Tokens({
    required this.access,
    required this.refresh,
    required this.expiresAt,
    required this.clientId,
  });
  final String access;
  final String refresh;
  final int expiresAt;
  final String clientId;
}
