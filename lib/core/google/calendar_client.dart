import 'dart:convert';

import 'package:http/http.dart' as http;

/// A thin, exact Calendar v3 client — hand-rolled like the desktop's
/// api.rs, because the wire details ARE the interop contract: pageToken
/// looping (which the desktop lacks and mobile must not), syncToken
/// persistence only from the final page, 410 → SYNC_TOKEN_EXPIRED, and
/// the extendedProperties that carry Threshold's identity.
class CalendarClient {
  CalendarClient(this._tokenProvider,
      {http.Client? inner, Future<void> Function()? onUnauthorized})
      : _http = inner ?? http.Client(),
        _onUnauthorized = onUnauthorized;

  final Future<String?> Function() _tokenProvider;
  final http.Client _http;

  /// Called on a 401 so the token cache can be dropped before ONE retry —
  /// Play Services occasionally hands back a token that just expired.
  final Future<void> Function()? _onUnauthorized;

  static const _base = 'https://www.googleapis.com/calendar/v3';

  /// Nothing here may hang: a wedged socket used to latch the app's
  /// one-sync-at-a-time and one-action-at-a-time guards closed forever,
  /// which read as "the buttons stopped working".
  static const _timeout = Duration(seconds: 30);

  Future<http.Response> _send(
    String method,
    String path,
    Map<String, String>? query,
    Object? body,
  ) async {
    final token = await _tokenProvider();
    if (token == null) throw const NotConnected();
    final uri = Uri.parse('$_base$path').replace(queryParameters: query);
    final req = http.Request(method, uri)
      ..headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(body);
    }
    final streamed = await _http.send(req).timeout(_timeout);
    return http.Response.fromStream(streamed).timeout(_timeout);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    var res = await _send(method, path, query, body);
    if (res.statusCode == 401 && _onUnauthorized != null) {
      await _onUnauthorized();
      res = await _send(method, path, query, body);
    }
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

  /// Channel-1 insert, byte-compatible with the desktop's ABI (§4.2 of the
  /// handoff): offset datetimes with no timeZone key, a 30-minute slot, the
  /// popup-10 reminder, and thresholdTaskUid (plus the legacy rowid when
  /// this task was born on the desktop).
  Future<({String id, String? htmlLink})> insertEvent({
    required String calendarId,
    required String title,
    required DateTime start,
    required String taskUid,
    int? legacyDesktopId,
  }) async {
    final res = await _request(
      'POST',
      '/calendars/${Uri.encodeComponent(calendarId)}/events',
      body: {
        'summary': title,
        'description': 'Scheduled by Threshold.',
        'start': {'dateTime': _rfc3339(start)},
        'end': {
          'dateTime': _rfc3339(start.add(const Duration(minutes: 30))),
        },
        'extendedProperties': {
          'private': {
            'thresholdTaskUid': taskUid,
            if (legacyDesktopId != null)
              'thresholdTaskId': '$legacyDesktopId',
          },
        },
        'reminders': {
          'useDefault': false,
          'overrides': [
            {'method': 'popup', 'minutes': 10},
          ],
        },
      },
    );
    final id = res['id'] as String?;
    if (id == null) throw const CalendarApiException(500, 'no event id');
    return (id: id, htmlLink: res['htmlLink'] as String?);
  }

  /// Moves are PATCH, start/end only — never delete+recreate, which breaks
  /// the desktop's cancelled-branch forever.
  Future<void> patchEventTime(
          String calendarId, String eventId, DateTime start) =>
      _request(
        'PATCH',
        '/calendars/${Uri.encodeComponent(calendarId)}/events/${Uri.encodeComponent(eventId)}',
        body: {
          'start': {'dateTime': _rfc3339(start)},
          'end': {
            'dateTime': _rfc3339(start.add(const Duration(minutes: 30))),
          },
        },
      );

  /// Claim an event as a Threshold task (adoption): patch the uid on,
  /// leaving everything else the user made intact.
  Future<void> claimEvent(
          String calendarId, String eventId, String taskUid) =>
      _request(
        'PATCH',
        '/calendars/${Uri.encodeComponent(calendarId)}/events/${Uri.encodeComponent(eventId)}',
        body: {
          'extendedProperties': {
            'private': {'thresholdTaskUid': taskUid},
          },
        },
      );

  Future<void> deleteEvent(String calendarId, String eventId) => _request(
        'DELETE',
        '/calendars/${Uri.encodeComponent(calendarId)}/events/${Uri.encodeComponent(eventId)}',
      );

  /// The duplicate guard: does an event for this task already exist? Two
  /// writers deciding "this task needs an event" must converge on one.
  Future<String?> findEventByUid(String calendarId, String taskUid) async {
    final res = await _request(
      'GET',
      '/calendars/${Uri.encodeComponent(calendarId)}/events',
      query: {
        'privateExtendedProperty': 'thresholdTaskUid=$taskUid',
        'maxResults': '2',
        'showDeleted': 'false',
      },
    );
    final items = res['items'] as List? ?? const [];
    if (items.isEmpty) return null;
    return (items.first as Map<String, dynamic>)['id'] as String?;
  }

  /// Busy intervals for the slotter, primary only, merged and opaque.
  Future<List<(DateTime, DateTime)>> freeBusy(
      DateTime min, DateTime max) async {
    final res = await _request('POST', '/freeBusy', body: {
      'timeMin': _rfc3339(min),
      'timeMax': _rfc3339(max),
      'items': [
        {'id': 'primary'},
      ],
    });
    final busy = (((res['calendars'] as Map<String, dynamic>?)?['primary']
                as Map<String, dynamic>?)?['busy'] as List?) ??
        const [];
    return [
      for (final b in busy)
        (
          DateTime.parse((b as Map<String, dynamic>)['start'] as String)
              .toLocal(),
          DateTime.parse(b['end'] as String).toLocal(),
        ),
    ];
  }

  /// Local time with its UTC offset, seconds precision, no timeZone key —
  /// the desktop's exact serialization.
  static String _rfc3339(DateTime t) {
    final local = t.toLocal();
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-'
        '${two(local.day)}T${two(local.hour)}:${two(local.minute)}:'
        '${two(local.second)}$sign${two(abs.inHours)}:'
        '${two(abs.inMinutes % 60)}';
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
