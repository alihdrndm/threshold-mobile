import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// The app-wide press signature: scale to 0.97 over 160ms on the house
/// curve, released on the same curve. Feedback lives on the press — the
/// interface answers the finger the instant it lands, not on release.
///
/// Reduced motion keeps the press (it is feedback, not travel) but any
/// caller-supplied entrance should be gated separately.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onPressed,
    this.large = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;

  /// Large surfaces move less — 0.99, the week-day rule.
  final bool large;
  final String? semanticLabel;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppDurations.press,
  );
  late final _scale = Tween<double>(
    begin: 1.0,
    end: widget.large ? AppPress.scaleLarge : AppPress.scale,
  ).animate(CurvedAnimation(parent: _controller, curve: AppPress.curve));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _controller.forward() : null,
        onTapUp: enabled
            ? (_) {
                _controller.reverse();
                widget.onPressed!();
              }
            : null,
        onTapCancel: enabled ? _controller.reverse : null,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}
