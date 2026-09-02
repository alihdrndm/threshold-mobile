import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:threshold_mobile/core/unlock/threshold_gate.dart';

void main() {
  group('ThresholdGate', () {
    late List<String> pushed;
    late int pops;
    late Completer<void> onScreen;
    late ThresholdGate gate;

    setUp(() {
      pushed = [];
      pops = 0;
      onScreen = Completer<void>();
      gate = ThresholdGate(
        push: (location) {
          pushed.add(location);
          // Like go_router: the future resolves when the surface pops.
          return onScreen.future;
        },
        pop: () {
          pops++;
          if (!onScreen.isCompleted) onScreen.complete();
        },
      );
    });

    test('a second arrival never stacks on an open threshold', () async {
      unawaited(gate.open('/ritual'));
      await Future<void>.delayed(Duration.zero);
      expect(gate.isOpen, isTrue);

      await gate.open('/ritual'); // the unlock that used to stack
      expect(pushed, ['/ritual'], reason: 'exactly one ritual');
    });

    test('two arrivals racing through the same tick open one surface',
        () async {
      // The old guard was read, then two SQLite round-trips were awaited
      // before pushing — wide enough for both to pass. The flag is now set
      // synchronously, so this cannot happen.
      unawaited(gate.open('/ritual'));
      unawaited(gate.open('/checkin/1'));
      await Future<void>.delayed(Duration.zero);
      expect(pushed, ['/ritual']);
    });

    test('locking dismisses the threshold, and the next one is fresh',
        () async {
      unawaited(gate.open('/ritual'));
      await Future<void>.delayed(Duration.zero);

      gate.dismiss();
      await Future<void>.delayed(Duration.zero);
      expect(pops, 1);
      expect(gate.isOpen, isFalse, reason: 'the door closed with the phone');

      // A fresh push is allowed again — a new screen, new state.
      onScreen = Completer<void>();
      unawaited(gate.open('/ritual'));
      await Future<void>.delayed(Duration.zero);
      expect(pushed, ['/ritual', '/ritual']);
    });

    test('dismiss on a closed gate pops nothing', () {
      gate.dismiss();
      expect(pops, 0,
          reason: 'a lock on the board must not pop the board');
    });

    test('the flag clears when the user leaves by the back gesture',
        () async {
      unawaited(gate.open('/ritual'));
      await Future<void>.delayed(Duration.zero);
      onScreen.complete(); // go_router resolves the push future on pop
      await Future<void>.delayed(Duration.zero);
      expect(gate.isOpen, isFalse);
    });
  });
}
