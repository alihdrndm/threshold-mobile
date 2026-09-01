import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A once-per-mount entrance: fade in and rise [rise] px on the house
/// curve, delayed `index × step` (capped) so groups cascade instead of
/// popping in together. State survives rebuilds, so it never replays on
/// data refreshes — only a fresh mount animates.
///
/// Reduced motion keeps the fade and drops the travel: gentler, not zero.
class ArriveIn extends StatefulWidget {
  const ArriveIn({
    super.key,
    required this.child,
    this.index = 0,
    this.step = AppDurations.staggerStep,
    this.cap = AppDurations.staggerCap,
    this.rise = 8,
  });

  final Widget child;
  final int index;
  final Duration step;
  final Duration cap;
  final double rise;

  @override
  State<ArriveIn> createState() => _ArriveInState();
}

class _ArriveInState extends State<ArriveIn>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(vsync: this, duration: AppDurations.cardIn);

  @override
  void initState() {
    super.initState();
    final delay = widget.step * widget.index;
    final capped = delay > widget.cap ? widget.cap : delay;
    Future<void>.delayed(capped, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = AppCurves.out.transform(_controller.value);
        return Opacity(
          opacity: t,
          child: reduce
              ? child
              : Transform.translate(
                  offset: Offset(0, widget.rise * (1 - t)),
                  child: child,
                ),
        );
      },
      child: widget.child,
    );
  }
}
