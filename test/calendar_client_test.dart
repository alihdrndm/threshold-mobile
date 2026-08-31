import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:threshold_mobile/core/google/calendar_client.dart';

void main() {
  CalendarClient clientWith(
      http.Response Function(http.Request) handler) {
    return CalendarClient(
      () async => 'token',
      inner: MockClient((req) async => handler(req)),
    );
  }

  test('pages until exhausted and keeps only the final sync token', () async {
    var calls = 0;
    final client = clientWith((req) {
      calls++;
      if (req.url.queryParameters['pageToken'] == null) {
        return http.Response(
            jsonEncode({
              'items': [
                {'id': 'a', 'summary': 'First'},
              ],
              'nextPageToken': 'p2',
              // Truncated pages carry no sync token.
            }),
            200);
      }
      return http.Response(
          jsonEncode({
            'items': [
              {'id': 'b', 'summary': 'Second'},
            ],
            'nextSyncToken': 'final-token',
          }),
          200);
    });

    final result = await client.listEvents('primary');
    expect(calls, 2);
    expect([for (final e in result.items) e.id], ['a', 'b']);
    expect(result.nextSyncToken, 'final-token');
  });

  test('410 surfaces as SyncTokenExpired', () async {
    final client = clientWith((_) => http.Response('gone', 410));
    expect(() => client.listEvents('primary', syncToken: 'stale'),
        throwsA(isA<SyncTokenExpired>()));
  });

  test('parses timed, all-day, and threshold-marked events', () {
    final timed = GEvent.fromJson({
      'id': 'e1',
      'summary': 'Dentist',
      'status': 'confirmed',
      'start': {'dateTime': '2026-09-01T09:15:00+05:00'},
      'end': {'dateTime': '2026-09-01T09:45:00+05:00'},
    });
    expect(timed.isAllDay, isFalse);
    expect(timed.isThreshold, isFalse);
    expect(timed.startTs, isNotNull);

    final allDay = GEvent.fromJson({
      'id': 'e2',
      'summary': 'Trip',
      'start': {'date': '2026-09-02'},
      'end': {'date': '2026-09-03'},
    });
    // The desktop drops all-day starts; mobile parses them.
    expect(allDay.isAllDay, isTrue);
    expect(allDay.startTs, isNotNull);

    final ours = GEvent.fromJson({
      'id': 'e3',
      'summary': 'French',
      'start': {'dateTime': '2026-09-01T08:00:00+05:00'},
      'extendedProperties': {
        'private': {'thresholdTaskId': '32'},
      },
    });
    expect(ours.isThreshold, isTrue,
        reason: 'a desktop-era rowid still marks the event as ours');

    final cancelled = GEvent.fromJson({'id': 'e4', 'status': 'cancelled'});
    expect(cancelled.cancelled, isTrue);
  });
}
