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
    duration: AppDurations.pressDown,
    reverseDuration: AppDurations.press,
  );
  late final _scale = Tween<double>(
    begin: 1.0,
    end: widget.large ? AppPress.scaleLarge : AppPress.scale,
  ).animate(CurvedAnimation(parent: _controller, curve: AppPress.curve));

  /// A quick tap inside a scrollable delivers tap-down and tap-up a frame
  /// apart (the gesture arena defers the down), so an immediate reverse
  /// showed nothing. Let the dip land, then release — the button always
  /// answers, however fast the finger.
  Future<void> _release() async {
    if (_controller.status == AnimationStatus.forward) {
      await _controller.forward().orCancel.catchError((Object _) {});
    }
    if (mounted) await _controller.reverse();
  }

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
                // The action never waits on the animation.
                widget.onPressed!();
                _release();
              }
            : null,
        onTapCancel: enabled ? _release : null,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}
