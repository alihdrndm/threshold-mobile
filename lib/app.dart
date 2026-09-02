import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'core/unlock/doorkeeper.dart';
import 'core/unlock/threshold_gate.dart';
import 'features/board_sync/presentation/board_sync_providers.dart';
import 'features/calendar_sync/presentation/sync_providers.dart';
import 'features/ritual/presentation/ritual_providers.dart';
import 'features/tasks/presentation/providers.dart';

class ThresholdApp extends ConsumerStatefulWidget {
  const ThresholdApp({super.key});

  @override
  ConsumerState<ThresholdApp> createState() => _ThresholdAppState();
}

class _ThresholdAppState extends ConsumerState<ThresholdApp> {
  AppLifecycleListener? _lifecycle;

  /// One door at a time, and it closes when the phone does.
  late final _gate = ThresholdGate(
    push: (location) => appRouter.push(location),
    pop: appRouter.pop,
  );

  @override
  void initState() {
    super.initState();
    // On open and on every return: missed repeats roll forward and a sync
    // pass runs — the mobile stand-in for the desktop's resident clock.
    // (The pass itself rolls first, then drains the outbox, then pulls.)
    // The doorkeeper's verdict: which threshold this open came through.
    // Cold starts consume the stored route; warm arrivals stream in.
    Doorkeeper.listen(_arrive);
    Future(() async {
      final route = await Doorkeeper.consumeRoute();
      if (route != null) _arrive(route);
      await Doorkeeper.start();
      await _settleSessions();
      await ref.read(taskRepositoryProvider).rollPastRepeats();
      await ref.read(calendarStatusProvider.notifier).syncNow();
      if (ref.read(firebaseReadyProvider)) {
        await ref.read(boardSyncProvider).start();
      }
    });
    _lifecycle = AppLifecycleListener(
      // The phone locked (or the app left): the threshold dies with it.
      // onPause, not onInactive — locking runs inactive→hidden→paused,
      // while pulling the notification shade stops at inactive, and a
      // shade pull must never kill a ritual mid-answer.
      onPause: _gate.dismiss,
      onResume: () async {
        final route = await Doorkeeper.consumeRoute();
        if (route != null) _arrive(route);
        // Every resume re-asserts the doorkeeper — cheap when it is
        // already standing, decisive when OneUI took it down.
        await Doorkeeper.start();
        await _settleSessions();
        await ref.read(taskRepositoryProvider).rollPastRepeats();
        await ref.read(calendarStatusProvider.notifier).syncNow();
        if (ref.read(firebaseReadyProvider)) {
          await ref.read(boardSyncProvider).start();
        }
      },
    );
  }

  /// Route an unlock to its threshold — unless a check-in is owed, which
  /// outranks both doors.
  void _arrive(String route) {
    Future(() async {
      if (_gate.isOpen) return;
      final awaiting =
          await ref.read(ritualRepositoryProvider).settle();
      if (awaiting != null) {
        await _gate.open('/checkin/${awaiting.id}');
        return;
      }
      // A running session already holds the commitment: no new ritual on
      // top of it, and the quote would only interrupt the work.
      final running =
          await ref.read(ritualRepositoryProvider).runningSession();
      if (running != null) return;
      if (route == 'ritual') {
        await _gate.open('/ritual');
      } else if (route == 'quote') {
        await _gate.open('/quote');
      }
    });
  }

  /// Sessions live by the clock even when nothing routed us here: a session
  /// past its end starts awaiting, one past the grace lapses, and an owed
  /// check-in is auto-opened ("also auto-routed on app open").
  Future<void> _settleSessions() async {
    final awaiting = await ref.read(ritualRepositoryProvider).settle();
    if (awaiting != null) {
      // Never awaited: the gate's future lives as long as the surface is
      // on screen, and the startup chain behind this (roll-forward, sync)
      // must not wait for the user to answer a check-in.
      unawaited(_gate.open('/checkin/${awaiting.id}'));
    }
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
