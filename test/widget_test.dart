import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threshold_mobile/app.dart';
import 'package:threshold_mobile/core/db/app_database.dart';
import 'package:threshold_mobile/features/tasks/presentation/providers.dart';

/// Widget tests pump with bounded durations rather than pumpAndSettle:
/// drift streams deliver on real microtasks, and an unbounded settle loop
/// against a live database is a deadlock waiting to happen.
/// Drift schedules a short keep-alive timer when query streams lose their
/// last listener; dispose the tree and flush it before the framework's
/// pending-timer assertion runs.
Future<void> tearDownApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

Future<void> pumpApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const ThresholdApp(),
    ),
  );
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(
        const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('the shell boots to the week; the board is one tab away',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await pumpApp(tester, db);

    // The week greets first (unconnected here, so it says how to fill it).
    expect(
        find.text('Connect Google Calendar in Settings to see your week.'),
        findsOneWidget);

    await tester.tap(find.text('BOARD'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('INBOX'), findsOneWidget);
    expect(find.text('New tasks land here'), findsOneWidget);
    expect(find.text('For what you can let go'), findsOneWidget);
    await tearDownApp(tester);
  });

  testWidgets('adding a task with #area files it and strips the tag',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await pumpApp(tester, db);
    await tester.tap(find.text('BOARD'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(
        find.byType(TextField).first, 'call mom #personal');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('call mom'), findsOneWidget);
    expect(find.text('PERSONAL'), findsOneWidget);
    await tearDownApp(tester);
  });
}
