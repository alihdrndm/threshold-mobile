import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_curves.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_curves.dart';
export 'app_durations.dart';
export 'app_spacing.dart';
export 'app_typography.dart';
export 'ritual_themes.dart';

/// Builds the two appearance themes from the token set. Dark is the base;
/// light is the ratio-matched override. State must resolve after
/// appearance, never compete with it.
ThemeData thresholdTheme(ThresholdColors c) {
  final text = AppTypography.textTheme(c.ink, c.inkMuted);
  return ThemeData(
    useMaterial3: true,
    brightness: c.brightness,
    fontFamily: AppTypography.family,
    scaffoldBackgroundColor: c.surface,
    canvasColor: c.surface,
    splashFactory: NoSplash.splashFactory, // press feedback is scale, not ink
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme(
      brightness: c.brightness,
      primary: c.accent,
      onPrimary: c.surface,
      secondary: c.accent,
      onSecondary: c.surface,
      // No red anywhere: the "error" role is the accent, and error surfaces
      // are accent-tinted washes.
      error: c.accent,
      onError: c.surface,
      surface: c.surface,
      onSurface: c.ink,
      outline: c.borderSubtle,
      surfaceContainerHighest: c.surfaceRaised,
    ),
    textTheme: text,
    dividerColor: c.borderSubtle,
    iconTheme: IconThemeData(color: c.inkMuted, size: 18),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        // Quiet fades on the house curve; travel belongs to the few
        // surfaces that earn it (the day morph, the ritual).
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    extensions: [c],
  );
}

/// System chrome that follows the surface — the mobile equivalent of
/// desktop's `color-scheme`, which existed because "declaring nothing is
/// why the dark dashboard has been drawing light scrollbars."
SystemUiOverlayStyle overlayStyleFor(ThresholdColors c) =>
    (c.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        .copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: c.surface,
    );

/// One press signature for the entire app: scale to 0.97 over 160ms on the
/// house curve (0.99 for large surfaces).
class AppPress {
  static const double scale = 0.97;
  static const double scaleLarge = 0.99;
  static const curve = AppCurves.out;
}
