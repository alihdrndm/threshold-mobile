import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threshold_mobile/app.dart';

void main() {
  testWidgets('the shell boots to the board with the zone invitations',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ThresholdApp()));
    await tester.pumpAndSettle();

    expect(find.text('INBOX'), findsOneWidget);
    expect(find.text('New tasks land here'), findsOneWidget);
    expect(find.text('For what you can let go'), findsOneWidget);
  });
}
