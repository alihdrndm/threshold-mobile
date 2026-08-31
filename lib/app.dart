import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'features/tasks/presentation/providers.dart';

class ThresholdApp extends ConsumerStatefulWidget {
  const ThresholdApp({super.key});

  @override
  ConsumerState<ThresholdApp> createState() => _ThresholdAppState();
}

class _ThresholdAppState extends ConsumerState<ThresholdApp> {
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    // Missed repeats come forward at the day boundary — on open and on
    // every return, the mobile stand-in for the desktop's resident clock.
    Future(() => ref.read(taskRepositoryProvider).rollPastRepeats());
    _lifecycle = AppLifecycleListener(
      onResume: () =>
          ref.read(taskRepositoryProvider).rollPastRepeats(),
    );
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value ?? const {};
    final mode = switch (settings['appearance']) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
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
