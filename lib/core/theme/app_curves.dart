import 'package:flutter/animation.dart';

/// The motion vocabulary. Two curves, and a rule: never ease-in on UI —
/// "it delays the exact moment the eye is watching most closely."
///
/// [out] is the house curve for every transform and entrance. It is NOT
/// Flutter's [Curves.easeOut]; the built-ins are too weak to read as
/// intentional. Colour tints may use plain ease ([Curves.ease]); constant
/// motion (a drain, a progress clock) uses linear. Nothing else exists —
/// there is no bounce, overshoot, or spring anywhere in this product:
/// "the one curve this app never speaks."
abstract final class AppCurves {
  static const Cubic out = Cubic(0.23, 1.0, 0.32, 1.0);
  static const Cubic inOut = Cubic(0.77, 0.0, 0.175, 1.0);
}
