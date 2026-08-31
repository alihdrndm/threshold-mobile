import 'package:flutter_test/flutter_test.dart';
import 'package:threshold_mobile/features/tasks/domain/areas_syntax.dart';

/// Parity with desktop `tasks/areas.ts`.
void main() {
  const areas = ['Job', 'Personal', 'Side'];

  group('parseTitle', () {
    test('only the first tag counts and it is stripped', () {
      final p = parseTitle('write brief #job for #personal', areas);
      expect(p.title, 'write brief for #personal');
      expect(p.areaName, 'Job');
    });

    test('matching is case-insensitive with canonical casing back', () {
      expect(parseTitle('x #JOB', areas).areaName, 'Job');
    });

    test('an unknown tag files arealess and reports the name', () {
      final p = parseTitle('water plants #garden', areas);
      expect(p.title, 'water plants');
      expect(p.areaName, isNull);
      expect(p.unknown, 'garden');
    });

    test('no tag, no area', () {
      final p = parseTitle('  just   a   task  ', areas);
      expect(p.title, 'just a task');
      expect(p.areaName, isNull);
      expect(p.unknown, isNull);
    });
  });

  group('tagAtCaret + suggestAreas', () {
    test('finds the partial under the caret', () {
      final hit = tagAtCaret('call mom #pe', 12);
      expect(hit?.partial, 'pe');
      expect(suggestAreas(hit!.partial, areas), ['Personal']);
    });

    test('no tag at caret, no popover', () {
      expect(tagAtCaret('plain text', 10), isNull);
      expect(tagAtCaret('a#b', 3), isNull, reason: 'mid-word # is not a tag');
    });
  });

  group('tidyAreaName', () {
    test('strips the syntax glyph and collapses whitespace', () {
      expect(tidyAreaName('  #Deep   Work '), 'Deep Work');
    });

    test('refuses empty and over-long names', () {
      expect(() => tidyAreaName(' # '), throwsFormatException);
      expect(() => tidyAreaName('x' * 25), throwsFormatException);
    });
  });
}
