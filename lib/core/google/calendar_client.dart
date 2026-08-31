import 'dart:convert';

import 'package:http/http.dart' as http;

/// A thin, exact Calendar v3 client — hand-rolled like the desktop's
/// api.rs, because the wire details ARE the interop contract: pageToken
/// looping (which the desktop lacks and mobile must not), syncToken
/// persistence only from the final page, 410 → SYNC_TOKEN_EXPIRED, and
/// the extendedProperties that carry Threshold's identity.
class CalendarClient {
  CalendarClient(this._tokenProvider, {http.Client? inner})
      : _http = inner ?? http.Client();

  final Future<String?> Function() _tokenProvider;
  final http.Client _http;

  static const _base = 'https://www.googleapis.com/calendar/v3';

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final token = await _tokenProvider();
    if (token == null) throw const NotConnected();
    final uri = Uri.parse('$_base$path').replace(queryParameters: query);
    final req = http.Request(method, uri)
      ..headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(body);
    }
    final res = await http.Response.fromStream(await _http.send(req));
    if (res.statusCode == 410) throw const SyncTokenExpired();
    // Idempotent deletes: 404 on DELETE is success (desktop rule; 410 was
    // already surfaced above as the sync-token signal).
    if (method == 'DELETE' &&
        (res.statusCode == 404 || res.statusCode == 204)) {
      return const {};
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw CalendarApiException(res.statusCode, res.body);
    }
    if (res.body.isEmpty) return const {};
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// One full listing pass: pageToken loop until exhausted, the sync token
  /// taken ONLY from the final page (a truncated page carries none, and
  /// persisting the absence would clear the cursor — the desktop's exact
  /// hole, closed here).
  Future<({List<GEvent> items, String? nextSyncToken})> listEvents(
    String calendarId, {
    String? syncToken,
    DateTime? timeMin,
  }) async {
    final items = <GEvent>[];
    String? pageToken;
    String? nextSyncToken;
    do {
      final query = <String, String>{
        'singleEvents': 'true',
        'showDeleted': 'true',
        'maxResults': '250',
        'pageToken': ?pageToken,
        if (pageToken == null && syncToken != null) 'syncToken': syncToken,
        if (pageToken == null && syncToken == null && timeMin != null)
          'timeMin': timeMin.toUtc().toIso8601String(),
      };
      final page = await _request(
          'GET', '/calendars/${Uri.encodeComponent(calendarId)}/events',
          query: query);
      for (final raw in (page['items'] as List? ?? const [])) {
        items.add(GEvent.fromJson(raw as Map<String, dynamic>));
      }
      pageToken = page['nextPageToken'] as String?;
      nextSyncToken = page['nextSyncToken'] as String?;
    } while (pageToken != null);
    return (items: items, nextSyncToken: nextSyncToken);
  }

  /// Find the app-created "Threshold" calendar, or make it. Patched
  /// unselected so it stays out of the user's normal Google views.
  Future<String> findOrCreateThresholdCalendar() async {
    final list = await _request('GET', '/users/me/calendarList');
    for (final raw in (list['items'] as List? ?? const [])) {
      final cal = raw as Map<String, dynamic>;
      if (cal['summary'] == 'Threshold') return cal['id'] as String;
    }
    final created = await _request('POST', '/calendars',
        body: {'summary': 'Threshold'});
    final id = created['id'] as String;
    try {
      await _request(
        'PATCH',
        '/users/me/calendarList/${Uri.encodeComponent(id)}',
        body: {'selected': false},
      );
    } on CalendarApiException {
      // Cosmetic; the calendar works either way.
    }
    return id;
  }

  void close() => _http.close();
}

/// The fields the read model keeps — a superset of desktop's EventItem,
/// because foreign events now carry their titles into the week view.
class GEvent {
  const GEvent({
    required this.id,
    required this.summary,
    required this.status,
    required this.eventType,
    required this.updated,
    this.startTs,
    this.endTs,
    this.isAllDay = false,
    this.thresholdTaskUid,
    this.thresholdTaskId,
    this.thresholdKind,
  });

  final String id;
  final String summary;
  final String status; // confirmed | tentative | cancelled
  final String eventType;
  final String updated;
  final int? startTs;
  final int? endTs;
  final bool isAllDay;
  final String? thresholdTaskUid;
  final String? thresholdTaskId;
  final String? thresholdKind;

  bool get cancelled => status == 'cancelled';
  bool get isThreshold => thresholdTaskUid != null || thresholdTaskId != null;

  static GEvent fromJson(Map<String, dynamic> e) {
    final private = ((e['extendedProperties']
            as Map<String, dynamic>?)?['private'] as Map<String, dynamic>?) ??
        const {};
    int? ts(String key) {
      final time = e[key] as Map<String, dynamic>?;
      if (time == null) return null;
      final dt = time['dateTime'] as String?;
      if (dt != null) {
        return DateTime.parse(dt).millisecondsSinceEpoch ~/ 1000;
      }
      final d = time['date'] as String?;
      if (d != null) {
        // All-day: local midnight of the named date — parsed, not dropped
        // (the desktop drops these; mobile shows them).
        return DateTime.parse(d).millisecondsSinceEpoch ~/ 1000;
      }
      return null;
    }

    final startRaw = e['start'] as Map<String, dynamic>?;
    return GEvent(
      id: e['id'] as String? ?? '',
      summary: e['summary'] as String? ?? '',
      status: e['status'] as String? ?? 'confirmed',
      eventType: e['eventType'] as String? ?? 'default',
      updated: e['updated'] as String? ?? '',
      startTs: ts('start'),
      endTs: ts('end'),
      isAllDay: startRaw != null && startRaw.containsKey('date'),
      thresholdTaskUid: private['thresholdTaskUid'] as String?,
      thresholdTaskId: private['thresholdTaskId'] as String?,
      thresholdKind: private['thresholdKind'] as String?,
    );
  }
}

class NotConnected implements Exception {
  const NotConnected();
  @override
  String toString() => 'Not connected - connect Google Calendar in Settings.';
}

class SyncTokenExpired implements Exception {
  const SyncTokenExpired();
}

class CalendarApiException implements Exception {
  const CalendarApiException(this.status, this.body);
  final int status;
  final String body;
  @override
  String toString() => 'Google answered $status.';
}
