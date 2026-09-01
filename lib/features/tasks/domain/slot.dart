/// Where the next free 30 minutes live — a port of desktop `slot.rs`,
/// which is the only judgement in the scheduling feature. Pure, so the
/// awkward cases are tested rather than discovered.
library;

class WorkingHours {
  const WorkingHours({
    this.startMin = 9 * 60,
    this.endMin = 18 * 60,
    this.days = const [true, true, true, true, true, false, false],
    this.bufferMin = 15,
  });

  /// Minutes past local midnight.
  final int startMin;
  final int endMin;

  /// Monday-first.
  final List<bool> days;
  final int bufferMin;

  static WorkingHours fromSettings(Map<String, String> s) {
    int parseClock(String? v, int fallback) {
      if (v == null) return fallback;
      final parts = v.split(':');
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0');
      if (h == null || m == null) return fallback;
      return h * 60 + m;
    }

    final days = List<bool>.filled(7, false);
    for (final piece in (s['work_days'] ?? '1,2,3,4,5').split(',')) {
      final n = int.tryParse(piece.trim());
      if (n != null && n >= 1 && n <= 7) days[n - 1] = true;
    }
    return WorkingHours(
      startMin: parseClock(s['work_start'], 540),
      endMin: parseClock(s['work_end'], 1080),
      days: days.contains(true)
          ? days
          : const [true, true, true, true, true, false, false],
      bufferMin: int.tryParse(s['cal_buffer_min'] ?? '') ?? 15,
    );
  }
}

/// The fixed slot length — a wire constant shared with the desktop.
const slotMinutes = 30;

DateTime _ceilQuarter(DateTime t) {
  final base = DateTime(t.year, t.month, t.day, t.hour, t.minute);
  final rem = base.minute % 15;
  if (rem == 0 && t.second == 0 && t.millisecond == 0) return base;
  return base.add(Duration(minutes: 15 - (rem == 0 ? 15 : rem)));
}

/// The earliest quarter-hour-aligned start of a 30-minute slot inside
/// working hours, avoiding every busy interval expanded by the buffer on
/// both sides. Two-week horizon; null means "no free slot in the next two
/// weeks - widen your working hours."
DateTime? nextFreeSlot(
  DateTime now,
  WorkingHours hours,
  List<(DateTime, DateTime)> busy,
) {
  var cursor = _ceilQuarter(now);
  final horizon = cursor.add(const Duration(days: 14));
  const slot = Duration(minutes: slotMinutes);
  final buffer = Duration(minutes: hours.bufferMin);
  var guard = 14 * 24 * 4 + 8;

  while (guard-- > 0 && cursor.isBefore(horizon)) {
    final midnight = DateTime(cursor.year, cursor.month, cursor.day);
    final open = midnight.add(Duration(minutes: hours.startMin));
    final close = midnight.add(Duration(minutes: hours.endMin));

    if (!hours.days[cursor.weekday - 1] || !cursor.isBefore(close)) {
      final next = midnight.add(const Duration(days: 1));
      cursor = next.add(Duration(minutes: hours.startMin));
      continue;
    }
    if (cursor.isBefore(open)) {
      cursor = open;
      continue;
    }
    if (cursor.add(slot).isAfter(close)) {
      final next = midnight.add(const Duration(days: 1));
      cursor = next.add(Duration(minutes: hours.startMin));
      continue;
    }

    final end = cursor.add(slot);
    DateTime? blockedUntil;
    for (final (bs, be) in busy) {
      final from = bs.subtract(buffer);
      final until = be.add(buffer);
      if (cursor.isBefore(until) && end.isAfter(from)) {
        if (blockedUntil == null || until.isAfter(blockedUntil)) {
          blockedUntil = until;
        }
      }
    }
    if (blockedUntil == null) return cursor;
    cursor = _ceilQuarter(blockedUntil);
  }
  return null;
}
