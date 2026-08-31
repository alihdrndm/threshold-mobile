import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';

/// The appearance axis: system | light | dark. Persisted to settings in M1;
/// an in-memory notifier until the database lands.
final appearanceProvider =
    NotifierProvider<AppearanceNotifier, ThemeMode>(AppearanceNotifier.new);

class AppearanceNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}

class ThresholdApp extends ConsumerWidget {
  const ThresholdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(appearanceProvider);
    final platformDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final dark = switch (mode) {
      ThemeMode.system => platformDark,
      ThemeMode.dark => true,
      ThemeMode.light => false,
    };
    final colors = dark ? ThresholdColors.dark : ThresholdColors.light;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyleFor(colors),
      child: MaterialApp.router(
        title: 'Threshold',
        debugShowCheckedModeBanner: false,
        theme: thresholdTheme(ThresholdColors.light),
        darkTheme: thresholdTheme(ThresholdColors.dark),
        themeMode: mode,
        routerConfig: appRouter,
      ),
    );
  }
}
