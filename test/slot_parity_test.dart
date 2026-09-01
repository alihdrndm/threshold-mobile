import 'package:flutter_test/flutter_test.dart';
import 'package:threshold_mobile/features/tasks/domain/slot.dart';

/// Parity with desktop slot.rs: quarter-hour grid, working-hours windows,
/// buffered avoidance, latest-offender jumps, the 14-day horizon.
void main() {
  DateTime at(int d, int h, [int m = 0]) => DateTime(2026, 6, d, h, m);
  const hours = WorkingHours(); // 09:00–18:00, Mon–Fri, buffer 15

  test('rounds up to the quarter hour inside open hours', () {
    // Monday 2026-06-01, 09:07 → 09:15.
    expect(nextFreeSlot(at(1, 9, 7), hours, []), at(1, 9, 15));
    expect(nextFreeSlot(at(1, 9, 15), hours, []), at(1, 9, 15));
  });

  test('before opening clamps to open; after close rolls to next day', () {
    expect(nextFreeSlot(at(1, 6, 30), hours, []), at(1, 9, 0));
    expect(nextFreeSlot(at(1, 19, 0), hours, []), at(2, 9, 0));
  });

  test('a weekend rolls to Monday', () {
    // 2026-06-06 is a Saturday.
    expect(nextFreeSlot(at(6, 10, 0), hours, []), at(8, 9, 0));
  });

  test('busy blocks repel by the buffer on both sides', () {
    final busy = [(at(1, 9, 0), at(1, 10, 0))];
    // 10:00 end + 15 min buffer → 10:15.
    expect(nextFreeSlot(at(1, 9, 0), hours, busy), at(1, 10, 15));
  });

  test('overlapping blocks resolve in one hop to the latest end', () {
    final busy = [
      (at(1, 9, 0), at(1, 9, 45)),
      (at(1, 9, 30), at(1, 11, 0)),
    ];
    expect(nextFreeSlot(at(1, 9, 0), hours, busy), at(1, 11, 15));
  });

  test('a slot must fit before close', () {
    // 17:45 + 30 min > 18:00 → tomorrow.
    expect(nextFreeSlot(at(1, 17, 40), hours, []), at(2, 9, 0));
  });

  test('a fully blocked fortnight yields null', () {
    final busy = [(at(1, 0, 0), DateTime(2026, 6, 30))];
    expect(nextFreeSlot(at(1, 9, 0), hours, busy), isNull);
  });
}
