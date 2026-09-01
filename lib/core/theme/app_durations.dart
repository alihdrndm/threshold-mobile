/// Durations, from the desktop token file. UI stays under 300ms; exits run
/// 25–30% faster than entrances ("the user has already decided, and waiting
/// on the old screen to leave is the part that feels slow"). The ambient
/// values are deliberately exempt from the sub-300ms rule — a breath made
/// fast "would defeat the entire point of it."
abstract final class AppDurations {
  /// Default for implicit tints and small state changes.
  static const base = Duration(milliseconds: 150);

  /// Press feedback and menu entrances.
  static const press = Duration(milliseconds: 160);

  /// The press DIP — faster than the release, so even the quickest tap
  /// shows a full pulse (snappy down, soft up).
  static const pressDown = Duration(milliseconds: 100);

  /// Card fade-in.
  static const cardIn = Duration(milliseconds: 180);

  /// Notices, scrims, week blocks.
  static const notice = Duration(milliseconds: 200);

  /// The saved dot; ritual step children.
  static const emphasis = Duration(milliseconds: 220);

  /// Window-scale entrances (corner cards, the wall).
  static const arrive = Duration(milliseconds: 260);

  /// The day-expansion morph open; the ritual glow.
  static const morph = Duration(milliseconds: 280);

  /// The day-expansion close — exits are faster.
  static const morphClose = Duration(milliseconds: 200);

  /// The breathing ring's full cycle.
  static const breath = Duration(seconds: 3);

  /// The wall glow's slower cycle — "a light breathes, a ring pulses."
  static const ambientGlow = Duration(seconds: 4);

  /// Stagger steps. Ritual children arrive 40ms apart (capped at 240);
  /// week blocks 12ms apart (capped at 120) — "a full calendar never feels
  /// slower than an empty one."
  static const staggerStep = Duration(milliseconds: 40);
  static const staggerCap = Duration(milliseconds: 240);
  static const weekStaggerStep = Duration(milliseconds: 12);
  static const weekStaggerCap = Duration(milliseconds: 120);
}
