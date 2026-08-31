import 'package:flutter/material.dart';

/// The board's five places plus the day's spent pile. Hue carries identity,
/// distance-from-the-page carries priority, and "nothing is red: alarm
/// colour just teaches you to stop seeing it" — Do First is warm amber.
enum Zone { inbox, doFirst, schedule, delegate, eliminate, done }

/// Every colour in the product, as a theme extension. Dark is the base
/// rather than a mode; light is a *ratio-matched* override, not an
/// inversion — ink lands at 16.5:1 against dark's 16.1:1, muted ink at
/// 5.98:1 against 6.02:1, and the accent is a different hue entirely
/// because #6b8afd reads at only 2.9:1 as text on light.
///
/// Nothing outside core/theme may name a colour. There is no error red:
/// error surfaces are accent-tinted ("red here would only teach the eye
/// that red means 'the thing I clicked on purpose'").
@immutable
class ThresholdColors extends ThemeExtension<ThresholdColors> {
  const ThresholdColors({
    required this.surface,
    required this.surfaceRaised,
    required this.fillSubtle,
    required this.fillSelected,
    required this.borderSubtle,
    required this.ink,
    required this.inkMuted,
    required this.accent,
    required this.glow,
    required this.zoneInkMuted,
    required this.zones,
    required this.brightness,
  });

  final Color surface;
  final Color surfaceRaised;
  final Color fillSubtle;
  final Color fillSelected;
  final Color borderSubtle;
  final Color ink;
  final Color inkMuted;
  final Color accent;
  final Color glow;

  /// Secondary text on a zone-tinted card — brighter than [inkMuted],
  /// because a card sits above the page and the base muted ink would fail
  /// contrast on the warmest wash.
  final Color zoneInkMuted;

  final Map<Zone, Color> zones;
  final Brightness brightness;

  /// The dark base.
  static const dark = ThresholdColors(
    surface: Color(0xFF0B0C0E),
    surfaceRaised: Color(0xFF141619),
    fillSubtle: Color(0x08FFFFFF),
    fillSelected: Color(0x1AFFFFFF),
    borderSubtle: Color(0x14FFFFFF),
    ink: Color(0xFFE8E9EB),
    inkMuted: Color(0xFF8B8F96),
    accent: Color(0xFF6B8AFD),
    glow: Color(0x336B8AFD),
    zoneInkMuted: Color(0xFF9BA0A8),
    zones: {
      Zone.inbox: Color(0xFF17191C),
      Zone.doFirst: Color(0xFF2A1F16),
      Zone.schedule: Color(0xFF14211F),
      Zone.delegate: Color(0xFF1E1A26),
      Zone.eliminate: Color(0xFF131417),
      Zone.done: Color(0xFF121316),
    },
    brightness: Brightness.dark,
  );

  /// The ratio-matched light palette. The page is #f7f7f5, "fractionally
  /// warm, so it reads as paper" — it must sit below white so a raised
  /// surface has somewhere to go.
  static const light = ThresholdColors(
    surface: Color(0xFFF7F7F5),
    surfaceRaised: Color(0xFFFFFFFF),
    fillSubtle: Color(0xFFFFFFFF),
    fillSelected: Color(0xFFE4E6EA),
    borderSubtle: Color(0x26000000),
    ink: Color(0xFF17181B),
    inkMuted: Color(0xFF5A5F68),
    accent: Color(0xFF4258D8),
    glow: Color(0x334258D8),
    zoneInkMuted: Color(0xFF565A61),
    zones: {
      Zone.inbox: Color(0xFFECEDF1),
      Zone.doFirst: Color(0xFFF8E5CD),
      Zone.schedule: Color(0xFFDFEEEA),
      Zone.delegate: Color(0xFFEEEAF8),
      Zone.eliminate: Color(0xFFF1F1F2),
      Zone.done: Color(0xFFF4F4F5),
    },
    brightness: Brightness.light,
  );

  Color zone(Zone z) => zones[z]!;

  /// A card's fill on its zone. Dark builds surfaces by adding light — the
  /// card must be *of* its zone; light removes tint — "white paper on a
  /// tinted board is the canonical reading."
  Color cardOn(Zone z) => brightness == Brightness.dark
      ? Color.alphaBlend(const Color(0x0FFFFFFF), zone(z))
      : surfaceRaised;

  /// A zone or card's edge, mixed from its own fill.
  Color borderOn(Zone z) => brightness == Brightness.dark
      ? Color.alphaBlend(const Color(0x21FFFFFF), zone(z))
      : Color.alphaBlend(const Color(0x2E000000), zone(z));

  /// The error surface: accent-tinted, never red.
  Color get errorFill => accent.withValues(alpha: 0.08);
  Color get errorBorder => accent.withValues(alpha: 0.50);

  @override
  ThresholdColors copyWith({Color? surface, Color? accent, Color? glow}) {
    return ThresholdColors(
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised,
      fillSubtle: fillSubtle,
      fillSelected: fillSelected,
      borderSubtle: borderSubtle,
      ink: ink,
      inkMuted: inkMuted,
      accent: accent ?? this.accent,
      glow: glow ?? this.glow,
      zoneInkMuted: zoneInkMuted,
      zones: zones,
      brightness: brightness,
    );
  }

  @override
  ThresholdColors lerp(ThresholdColors? other, double t) {
    if (other == null) return this;
    return ThresholdColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      fillSubtle: Color.lerp(fillSubtle, other.fillSubtle, t)!,
      fillSelected: Color.lerp(fillSelected, other.fillSelected, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      zoneInkMuted: Color.lerp(zoneInkMuted, other.zoneInkMuted, t)!,
      zones: {
        for (final z in Zone.values) z: Color.lerp(zones[z], other.zones[z], t)!,
      },
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}

extension ThresholdColorsX on BuildContext {
  ThresholdColors get colors => Theme.of(this).extension<ThresholdColors>()!;
}
