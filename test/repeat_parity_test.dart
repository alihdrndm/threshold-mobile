import 'package:flutter_test/flutter_test.dart';
import 'package:threshold_mobile/features/tasks/domain/repeat.dart';

/// Port-parity vectors from desktop `calendar/repeat.rs`. Both devices must
/// roll the same repeat to the same instant — these are wire-contract
/// tests, not unit tests.
void main() {
  DateTime at(int y, int mo, int d, int h, int mi) => DateTime(y, mo, d, h, mi);
  final daily = List<bool>.filled(7, true);

  group('nextOccurrence', () {
    test('a daily task comes back tomorrow', () {
      // 2026-06-01 is a Monday.
      expect(nextOccurrence(at(2026, 6, 1, 9, 0), daily, 9, 0),
          at(2026, 6, 2, 9, 0));
    });

    test('the same day never matches', () {
      final days = dayMask('1,3');
      expect(nextOccurrence(at(2026, 6, 1, 9, 0), days, 9, 0),
          at(2026, 6, 3, 9, 0));
    });

    test('a single-day mask waits a full week', () {
      expect(nextOccurrence(at(2026, 6, 1, 9, 0), dayMask('1'), 9, 0),
          at(2026, 6, 8, 9, 0));
    });

    test('the search wraps past Sunday', () {
      // Tuesday mask, completed on Saturday 2026-06-06.
      expect(nextOccurrence(at(2026, 6, 6, 14, 0), dayMask('2'), 14, 0),
          at(2026, 6, 9, 14, 0));
    });

    test('an empty mask is no repeat', () {
      expect(nextOccurrence(at(2026, 6, 1, 9, 0), List.filled(7, false), 9, 0),
          isNull);
    });

    test('minutes survive the advance', () {
      final next = nextOccurrence(at(2026, 6, 1, 9, 30), daily, 9, 30)!;
      expect((next.hour, next.minute), (9, 30));
    });
  });

  group('rollForward', () {
    test('a missed daily rolls to today at its own time', () {
      final rolled = rollForward(
          at(2026, 6, 1, 9, 30), daily, at(2026, 6, 4, 0, 0))!;
      expect(rolled, at(2026, 6, 4, 9, 30));
    });

    test('a weekly ritual skips to its next day, not to today', () {
      final rolled = rollForward(
          at(2026, 6, 1, 9, 0), dayMask('1'), at(2026, 6, 3, 0, 0))!;
      expect(rolled, at(2026, 6, 8, 9, 0), reason: 'next Monday, not midweek');
    });

    test('an anchor already current stays put', () {
      final anchor = at(2026, 6, 1, 8, 0);
      expect(rollForward(anchor, daily, at(2026, 6, 1, 0, 0)), anchor);
      final future = at(2026, 6, 5, 8, 0);
      expect(rollForward(future, daily, at(2026, 6, 1, 0, 0)), future);
    });

    test('a long absence becomes one slot, not a backlog', () {
      final rolled = rollForward(
          at(2026, 6, 1, 9, 0), dayMask('1,2,3,4,5'), at(2026, 7, 11, 0, 0))!;
      expect(rolled, at(2026, 7, 13, 9, 0), reason: 'Monday the 13th');
    });

    test('rolling an empty mask is nothing', () {
      expect(
          rollForward(at(2026, 6, 1, 9, 0), List.filled(7, false),
              at(2026, 6, 4, 0, 0)),
          isNull);
    });
  });

  group('normalizeDays', () {
    test('tidies and refuses like the desktop', () {
      expect(normalizeDays('5,3,3,1'), '1,3,5');
      expect(normalizeDays(' 2 '), '2');
      expect(normalizeDays('1,2,3,4,5,6,7'), '1,2,3,4,5,6,7');
      expect(() => normalizeDays('0'), throwsFormatException);
      expect(() => normalizeDays('8'), throwsFormatException);
      expect(() => normalizeDays('mon'), throwsFormatException);
      expect(() => normalizeDays(''), throwsFormatException);
    });
  });

  group('formatRepeat', () {
    test('names every day as one phrase', () {
      expect(formatRepeat(daily), 'Every day');
      expect(formatRepeat(dayMask('1,3,5')), 'Mon, Wed, Fri');
    });
  });
}
