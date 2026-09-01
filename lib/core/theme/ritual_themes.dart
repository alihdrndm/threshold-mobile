import 'package:flutter/material.dart';

/// The ritual rotates its look *and* its interaction daily, "because
/// identical dialogs are neurologically habituated within a handful of
/// exposures — precisely the autopilot this app exists to interrupt."
/// The prediction prompt never rotates: "each [question] is carrying a
/// specific effect and rewording them into something softer would quietly
/// throw that away."
///
/// The ritual is always dark, whatever the appearance setting — "a white
/// fullscreen window at boot is not a kindness."
enum IntentionMode { type, choose }

enum DurationMode { chips, slider }

@immutable
class RitualTheme {
  const RitualTheme({
    required this.id,
    required this.surface,
    required this.accent,
    required this.glow,
    required this.intentionMode,
    required this.durationMode,
    required this.greeting,
    required this.intentionPrompt,
    required this.ifThenPrompt,
    required this.durationPrompt,
  });

  final String id;
  final Color surface;
  final Color accent;
  final Color glow;
  final IntentionMode intentionMode;
  final DurationMode durationMode;
  final String greeting;
  final String intentionPrompt;
  final String ifThenPrompt;
  final String durationPrompt;

  /// Identical across all four themes, on purpose.
  static const predictionPrompt =
      'Will you start this before opening anything else?';
}

const ritualThemes = <RitualTheme>[
  RitualTheme(
    id: 'ash',
    surface: Color(0xFF0B0C0E),
    accent: Color(0xFF6B8AFD),
    glow: Color(0x336B8AFD),
    intentionMode: IntentionMode.type,
    durationMode: DurationMode.chips,
    greeting: 'Fresh session.',
    // The arrival now opens with "What are you here for?" on every theme
    // (user's call), so ash's intention step invites the answer instead of
    // repeating the question.
    intentionPrompt: 'Say it in a few words.',
    ifThenPrompt: 'If I feel the urge to open a feed, then I will…',
    durationPrompt: 'How long?',
  ),
  RitualTheme(
    id: 'ember',
    surface: Color(0xFF0E0B0A),
    accent: Color(0xFFE8A06B),
    glow: Color(0x2EE8A06B),
    intentionMode: IntentionMode.choose,
    durationMode: DurationMode.slider,
    greeting: 'Back at it.',
    intentionPrompt: 'What deserves this hour?',
    ifThenPrompt: 'When the pull comes, then I will…',
    durationPrompt: 'Commit how much?',
  ),
  RitualTheme(
    id: 'tide',
    surface: Color(0xFF080D0D),
    accent: Color(0xFF5FC7B8),
    glow: Color(0x2E5FC7B8),
    intentionMode: IntentionMode.type,
    durationMode: DurationMode.slider,
    greeting: 'Here again.',
    intentionPrompt: 'What are you starting?',
    ifThenPrompt: 'If a feed calls, then I will…',
    durationPrompt: 'For how long?',
  ),
  RitualTheme(
    id: 'dusk',
    surface: Color(0xFF0C0A0F),
    accent: Color(0xFFA98BF0),
    glow: Color(0x2EA98BF0),
    intentionMode: IntentionMode.choose,
    durationMode: DurationMode.chips,
    greeting: 'New start.',
    intentionPrompt: 'Where is your attention going?',
    ifThenPrompt: 'If I reach for a feed, then I will…',
    durationPrompt: 'How long?',
  ),
];

/// Derived from the local calendar day, never stored — "a reinstall cannot
/// accidentally serve the same day twice."
RitualTheme ritualThemeFor(DateTime now) {
  final midnight = DateTime(now.year, now.month, now.day);
  final days = midnight.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return ritualThemes[days % ritualThemes.length];
}
