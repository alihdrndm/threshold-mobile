/// When a repeating task comes back: the next matching day, same wall-clock
/// time. A direct port of desktop `calendar/repeat.rs` — the semantics are
/// a wire contract now (both devices must roll the same repeat to the same
/// instant), so change nothing here without changing it there.
///
/// "A repeating task is a ritual, and a ritual keeps its time. Conflicts
/// stay visible on the week panel, where the person - not an algorithm -
/// decides which one moves."
library;

/// Tidy a "5,3,3,1" mask into "1,3,5": digits 1-7 (Mon=1..Sun=7), deduped,
/// ascending. Anything else — or an empty result — is an error: "a repeat
/// with no days is 'off', and off is spelled null, not ''."
String normalizeDays(String raw) {
  final days = List<bool>.filled(7, false);
  for (final piece in raw.split(',')) {
    final p = piece.trim();
    if (p.isEmpty) continue;
    final n = int.tryParse(p);
    if (n == null || n < 1 || n > 7) {
      throw FormatException('not a weekday (1-7): $p');
    }
    days[n - 1] = true;
  }
  final listed = [
    for (var i = 0; i < 7; i++)
      if (days[i]) '${i + 1}',
  ];
  if (listed.isEmpty) {
    throw const FormatException('a repeat needs at least one day');
  }
  return listed.join(',');
}

/// "1,3,5" -> Monday-first [bool; 7]. Junk days are ignored (the storage
/// layer already normalized; this is the read side).
List<bool> dayMask(String raw) {
  final days = List<bool>.filled(7, false);
  for (final piece in raw.split(',')) {
    final n = int.tryParse(piece.trim());
    if (n != null && n >= 1 && n <= 7) days[n - 1] = true;
  }
  return days;
}

/// The next date STRICTLY after [after]'s date whose weekday is in [days],
/// at hour:minute local wall-clock. Same-day never matches: completing
/// Monday's task with Monday in the mask goes to NEXT Monday.
///
/// DST-safe the way a wall clock is: Dart's local DateTime constructor
/// resolves ambiguous and nonexistent wall times itself, keeping the named
/// hour where one exists — matching the Rust port's intent.
DateTime? nextOccurrence(DateTime after, List<bool> days, int hour, int minute) {
  if (!days.contains(true)) return null;
  for (var step = 1; step <= 7; step++) {
    final date = DateTime(after.year, after.month, after.day + step);
    if (days[date.weekday - 1]) {
      return DateTime(date.year, date.month, date.day, hour, minute);
    }
  }
  return null;
}

/// Where a missed ritual belongs now: the earliest occurrence of [anchor]'s
/// pattern landing on [today] or later, same wall-clock time. "It steps
/// through the days that were slept through without piling them up - a week
/// of missed dailies becomes one slot today, not seven behind you."
DateTime? rollForward(DateTime anchor, List<bool> days, DateTime today) {
  final todayDate = DateTime(today.year, today.month, today.day);
  var current = anchor;
  // Each step strictly advances a day; the bound only guards a wild clock.
  for (var i = 0; i <= 366; i++) {
    final currentDate = DateTime(current.year, current.month, current.day);
    if (!currentDate.isBefore(todayDate)) return current;
    final next = nextOccurrence(current, days, anchor.hour, anchor.minute);
    if (next == null) return null;
    current = next;
  }
  return null;
}

/// "Every day" or day names — the card and panel caption vocabulary.
String formatRepeat(List<bool> days) {
  if (days.every((d) => d)) return 'Every day';
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return [
    for (var i = 0; i < 7; i++)
      if (days[i]) names[i],
  ].join(', ');
}
