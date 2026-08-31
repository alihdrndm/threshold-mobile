/// The spacing rhythm. Card padding is 12×10; zones breathe at 16; the gap
/// between cards (8) to the gap between zones (12) keeps grouping legible
/// without drawing lines — a deliberate 1:1.5 ratio.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Gap between stacked cards.
  static const double cardGap = 8;

  /// Gap between board zones.
  static const double zoneGap = 12;
}

/// Radius scales with the size of the container, and "interactive = fully
/// round" is absolute — every pressable and every typable surface is a pill.
abstract final class AppRadii {
  static const double block = 5; // week blocks
  static const double item = 8; // menu items, inputs
  static const double card = 12; // task cards, popovers, notices
  static const double zone = 16; // zones, tiles, sheets
  static const double wall = 24; // the largest surface
  static const double full = 9999; // everything pressable or typable
}
