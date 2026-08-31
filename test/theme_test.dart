import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threshold_mobile/core/theme/theme.dart';

void main() {
  group('the token contract', () {
    test('dark and light palettes carry the audited values', () {
      expect(ThresholdColors.dark.surface, const Color(0xFF0B0C0E));
      expect(ThresholdColors.dark.accent, const Color(0xFF6B8AFD));
      expect(ThresholdColors.dark.ink, const Color(0xFFE8E9EB));
      // Light is ratio-matched, not inverted: a different accent hue.
      expect(ThresholdColors.light.surface, const Color(0xFFF7F7F5));
      expect(ThresholdColors.light.accent, const Color(0xFF4258D8));
      expect(
        ThresholdColors.light.accent,
        isNot(ThresholdColors.dark.accent),
      );
    });

    test('nothing is red - Do First is warm amber in both schemes', () {
      for (final palette in [ThresholdColors.dark, ThresholdColors.light]) {
        final amber = palette.zone(Zone.doFirst);
        final hsl = HSLColor.fromColor(amber);
        expect(hsl.hue, inInclusiveRange(20, 50),
            reason: 'Do First must stay amber, never red');
      }
    });

    test('the house curve is the audited cubic, not a built-in', () {
      expect(AppCurves.out, const Cubic(0.23, 1.0, 0.32, 1.0));
      expect(AppCurves.out, isNot(Curves.easeOut));
    });

    test('exits are faster than entrances', () {
      expect(AppDurations.morphClose, lessThan(AppDurations.morph));
    });

    test('press feedback is the 0.97 signature', () {
      expect(AppPress.scale, 0.97);
      expect(AppPress.scaleLarge, 0.99);
    });

    test('the ritual rotation is date-derived and the prediction never rotates', () {
      final a = ritualThemeFor(DateTime(2026, 6, 1));
      final b = ritualThemeFor(DateTime(2026, 6, 2));
      expect(a.id, isNot(b.id));
      expect(ritualThemeFor(DateTime(2026, 6, 5)).id, a.id,
          reason: 'four themes, four-day cycle');
      expect(RitualTheme.predictionPrompt,
          'Will you start this before opening anything else?');
    });
  });
}
