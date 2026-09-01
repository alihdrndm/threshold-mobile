import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threshold_mobile/core/db/app_database.dart';
import 'package:threshold_mobile/features/ritual/data/ritual_repository.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late RitualRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    now = DateTime(2026, 9, 1, 9, 0);
    repo = RitualRepository(db, clock: () => now);
  });

  tearDown(() => db.close());

  test('at most one session may run - the second commit fails loudly',
      () async {
    await repo.beginSession(intentionText: 'first', durationMin: 50);
    expect(
      () => repo.beginSession(intentionText: 'second', durationMin: 25),
      throwsA(anything),
    );
  });

  test('a session lives by the clock: running, awaiting, then lapsed',
      () async {
    final id = await repo.beginSession(
        intentionText: 'write the essay', durationMin: 25);
    expect((await repo.runningSession())?.id, id);
    expect(await repo.settle(), isNull, reason: 'still running');

    // Time passes its end: the session starts awaiting its check-in.
    now = now.add(const Duration(minutes: 26));
    final awaiting = await repo.settle();
    expect(awaiting?.id, id);
    expect(awaiting?.state, 'awaiting_checkin');

    // Ten more minutes of silence: it lapses, silently.
    now = now.add(const Duration(minutes: 11));
    expect(await repo.settle(), isNull);
    expect((await repo.byId(id))?.state, 'lapsed');
  });

  test('an answered check-in keeps its verdict and never lapses', () async {
    final id = await repo.beginSession(
        intentionText: 'read the paper', durationMin: 25);
    now = now.add(const Duration(minutes: 30));
    final awaiting = await repo.settle();
    await repo.answer(awaiting!.id, 'partly');
    now = now.add(const Duration(hours: 2));
    await repo.settle();
    final session = await repo.byId(id);
    expect(session?.state, 'partly');
    expect(session?.answeredTs, isNotNull);
  });

  test('ending early goes straight to the check-in, not to lapse', () async {
    final id =
        await repo.beginSession(intentionText: 'deep work', durationMin: 90);
    now = now.add(const Duration(minutes: 10));
    await repo.endEarly(id);
    final awaiting = await repo.settle();
    expect(awaiting?.id, id);
  });

  test('the reservoir: unique text, 280-char cap, clock bumps on change',
      () async {
    await repo.addQuote('The urge will pass whether you feed it or not.',
        author: 'me, later');
    await repo.addQuote('The urge will pass whether you feed it or not.');
    expect((await repo.quotes()).length, 1,
        reason: 'the same words twice is a mistake, not a preference');
    expect(() => repo.addQuote('x' * 281), throwsArgumentError);
    expect(() => repo.addQuote('   '), throwsArgumentError);

    final clock = await (db.select(db.settingsKV)
          ..where((s) => s.key.equals('quotes_updated_ts')))
        .getSingleOrNull();
    expect(clock, isNotNull, reason: 'the board channel needs the LWW clock');

    await repo
        .removeQuote('The urge will pass whether you feed it or not.');
    expect(await repo.quotes(), isEmpty);
    expect(await repo.randomQuote(), isNull,
        reason: 'an empty reservoir shows nothing');
  });

  test('browsing is recorded, never judged', () async {
    await repo.recordBrowsing();
    final rows = await db.select(db.intentions).get();
    expect(rows.single.outcome, 'browsing');
    expect(await repo.runningSession(), isNull);
  });
}
