import 'package:flutter_test/flutter_test.dart';
import 'package:threshold_mobile/core/db/app_database.dart';
import 'package:threshold_mobile/features/board_sync/domain/board_doc_codec.dart';
import 'package:threshold_mobile/features/tasks/domain/quadrant.dart';

void main() {
  group('BoardDoc codec', () {
    test('row → doc → map → doc round-trips every synced field', () {
      final row = TaskRow(
        id: 7,
        uid: 'u-1',
        title: 'Ship the port',
        note: 'with care',
        areaUid: 'seed-job',
        urgent: false,
        important: true,
        sortOrder: 3,
        status: 'open',
        createdTs: '2026-08-31T10:00:00.000',
        completedTs: null,
        scheduledTs: 1788300000,
        calendarEventId: 'evt-9',
        calendarHtmlLink: null,
        repeatDays: '1,3,5',
        remindFiredForTs: null,
        remindSnoozedUntil: null,
        boardEventId: null,
        legacyDesktopId: 42,
        updatedTs: 1788250000,
      );
      final doc = BoardDoc.fromRow(row, areaName: 'Job');
      final back = BoardDoc.fromMap('u-1', doc.toMap())!;

      expect(back.title, 'Ship the port');
      expect(back.note, 'with care');
      expect(back.quadrant, Quadrant.schedule);
      expect(back.status, 'open');
      expect(back.sortOrder, 3);
      expect(back.area, 'Job');
      expect(back.repeatDays, '1,3,5');
      expect(back.scheduledTs, 1788300000);
      expect(back.completedTs, isNull);
      expect(back.updatedTs, 1788250000);
      expect(back.legacyDesktopId, 42);
      // Per-device state never travels.
      expect(doc.toMap().containsKey('calendarEventId'), isFalse);
      expect(doc.toMap().containsKey('boardEventId'), isFalse);
    });

    test('quadrant wire values are the desktop spellings', () {
      expect(BoardDoc.fromRow(_bare(urgent: true, important: true))
          .toMap()['quadrant'], 'do_first');
      expect(BoardDoc.fromRow(_bare()).toMap()['quadrant'], 'inbox');
      expect(quadrantFromWire('delegate'), Quadrant.delegate);
      expect(quadrantFromWire('nonsense'), Quadrant.inbox);
      expect(quadrantFromWire(null), Quadrant.inbox);
    });

    test('malformed documents decode to null, never throw', () {
      expect(BoardDoc.fromMap('u', {}), isNull);
      expect(BoardDoc.fromMap('u', {'title': 'x'}), isNull);
      expect(BoardDoc.fromMap('u', {'title': 'x', 'updatedTs': 'soon'}),
          isNull);
    });

    test('areas meta round-trips and tolerates junk entries', () {
      final map = areasToMap(
          [(name: 'Job', sortOrder: 0), (name: 'Side', sortOrder: 1)], 99);
      final decoded = areasFromMap(map)!;
      expect(decoded.$2, 99);
      expect(decoded.$1.map((a) => a.name), ['Job', 'Side']);

      final dirty = areasFromMap({
        'updatedTs': 5,
        'areas': [
          {'name': 'Real', 'sortOrder': 0},
          {'sortOrder': 1},
          'garbage',
        ],
      })!;
      expect(dirty.$1.map((a) => a.name), ['Real']);
      expect(areasFromMap({'areas': []}), isNull);
    });
  });
}

TaskRow _bare({bool? urgent, bool? important}) => TaskRow(
      id: 1,
      uid: 'u',
      title: 't',
      note: null,
      areaUid: null,
      urgent: urgent,
      important: important,
      sortOrder: 0,
      status: 'open',
      createdTs: '2026-09-01T00:00:00.000',
      completedTs: null,
      scheduledTs: null,
      calendarEventId: null,
      calendarHtmlLink: null,
      repeatDays: null,
      remindFiredForTs: null,
      remindSnoozedUntil: null,
      boardEventId: null,
      legacyDesktopId: null,
      updatedTs: 10,
    );
