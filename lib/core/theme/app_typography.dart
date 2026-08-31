import 'package:flutter/material.dart';

/// Inter, bundled. Weights 300/400/500 only — emphasis is carried by
/// contrast and size, never by bold or colour. The signature treatment is
/// the tracked-caps label voice: 10sp, +0.14em, uppercase, muted ink —
/// area chips, slot chips, day headers, legends, panel headers.
///
/// Tracking scales inversely with size and directly with "how much of a
/// label this is." Numbers that sit in columns or change in place use
/// tabular figures so "ten tasks do not push every title a pixel sideways."
abstract final class AppTypography {
  static const family = 'Inter';

  static const tabular = [FontFeature.tabularFigures()];

  /// em-tracking helper: CSS `letter-spacing: Xem` → logical pixels.
  static double _em(double em, double size) => em * size;

  /// The label voice. Callers uppercase the text themselves (CapsLabel does).
  static TextStyle labelCaps({double size = 10}) => TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: FontWeight.w400,
        letterSpacing: _em(0.14, size),
        height: 1.4,
      );

  /// Zone headers: 12sp, w500, +0.18em, full ink — "a zone is a place,
  /// not a caption."
  static TextStyle zoneHeader = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: _em(0.18, 12),
    height: 1.4,
  );

  /// Stat labels: 12sp, +0.16em.
  static TextStyle statLabel = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: _em(0.16, 12),
    height: 1.4,
  );

  /// Axis labels and citations: 11sp, +0.22em.
  static TextStyle axisLabel = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: _em(0.22, 11),
    height: 1.4,
  );

  /// Ritual eyebrows: 12sp, +0.24em, ink at 50%.
  static TextStyle eyebrow = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: _em(0.24, 12),
    height: 1.4,
  );

  /// The body of the whole app.
  static const body = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Task titles: body-sized, snug leading; wraps, never truncates —
  /// "a clipped title hides exactly the words that distinguish two
  /// similar tasks."
  static const taskTitle = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.375,
  );

  /// Secondary metadata.
  static const caption = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Corner-card headlines.
  static const headline = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Stat values and the slider readout.
  static const statValue = TextStyle(
    fontFamily: family,
    fontSize: 24,
    fontWeight: FontWeight.w300,
    height: 1.2,
    fontFeatures: tabular,
  );

  /// The ritual Question: display-light, tight, centered, balanced.
  static const question = TextStyle(
    fontFamily: family,
    fontSize: 30,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static TextTheme textTheme(Color ink, Color inkMuted) => TextTheme(
        bodyMedium: body.copyWith(color: ink),
        bodySmall: caption.copyWith(color: inkMuted),
        titleMedium: headline.copyWith(color: ink),
        headlineMedium: question.copyWith(color: ink),
        labelSmall: labelCaps().copyWith(color: inkMuted),
      );
}
