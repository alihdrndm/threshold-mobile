import 'dart:async';

/// One door at a time.
///
/// The old guard asked the router what was on screen — and go_router's
/// `currentConfiguration.uri` deliberately ignores imperative pushes, so
/// the answer was always "the tab underneath" and every unlock stacked
/// another ritual on the abandoned one. This owns the fact instead: the
/// flag is set synchronously BEFORE any await, so two arrivals racing
/// through a pair of SQLite reads still open exactly one surface.
///
/// [push] is expected to resolve when the surface is popped (go_router's
/// does), which is what keeps [isOpen] true for exactly as long as the
/// threshold is standing — including when the user leaves by the back
/// gesture rather than through the ritual.
class ThresholdGate {
  ThresholdGate({required this.push, required this.pop});

  final Future<void> Function(String location) push;
  final void Function() pop;

  bool _open = false;

  bool get isOpen => _open;

  Future<void> open(String location) async {
    if (_open) return;
    _open = true;
    try {
      await push(location);
    } finally {
      _open = false;
    }
  }

  /// The phone locked, or the app went away: the threshold dies with it,
  /// so the next unlock starts fresh rather than resuming a ritual the
  /// user already walked out on.
  void dismiss() {
    if (_open) pop();
  }
}
