import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threshold_mobile/core/db/app_database.dart';
import 'package:threshold_mobile/features/tasks/data/task_repository.dart';
import 'package:threshold_mobile/features/tasks/domain/quadrant.dart';
import 'package:threshold_mobile/features/tasks/domain/task.dart';

/// The desktop's `db/tasks.rs` invariants, re-proven against the drift
/// store. The clock is injected so advance/roll math is tested to the day.
void main() {
  late AppDatabase db;
  late TaskRepository repo;
  var now = DateTime(2026, 6, 1, 10, 0); // a Monday

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TaskRepository(db, clock: () => now);
  });

  tearDown(() => db.close());

  Future<Task> byUid(String uid) async =>
      (await repo.watchAll().first).firstWhere((t) => t.uid == uid);

  test('the seed areas exist', () async {
    final names = (await repo.watchAreas().first).map((a) => a.name);
    expect(names, containsAll(['Job', 'Personal', 'Side']));
  });

  test('new tasks join the end of the Inbox', () async {
    final a = await repo.add('first');
    final b = await repo.add('second');
    expect((await byUid(a)).sortOrder, lessThan((await byUid(b)).sortOrder));
    expect((await byUid(b)).quadrant, Quadrant.inbox);
  });

  test('leaving Schedule clears the repeat, the slot, and the reminders',
      () async {
    final uid = await repo.add('ritual');
    await repo.moveToQuadrant(uid, Quadrant.schedule);
    await repo.setRepeat(uid, '5,1');
    await repo.setSchedule(uid, 1_700_000_000);
    expect((await byUid(uid)).repeatDays, '1,5');

    await repo.moveToQuadrant(uid, Quadrant.doFirst);
    final t = await byUid(uid);
    expect(t.repeatDays, isNull,
        reason: 'dragged to Do First must not come back next Tuesday');
    expect(t.scheduledTs, isNull);
    expect(t.remindSnoozedUntil, isNull);
  });

  test('a move within Schedule keeps the repeat', () async {
    final uid = await repo.add('ritual');
    await repo.moveToQuadrant(uid, Quadrant.schedule);
    await repo.setRepeat(uid, '1,3');
    await repo.moveToQuadrant(uid, Quadrant.schedule);
    expect((await byUid(uid)).repeatDays, '1,3');
  });

  test('completing a repeating Schedule task advances instead of finishing',
      () async {
    final uid = await repo.add('daily pages');
    await repo.moveToQuadrant(uid, Quadrant.schedule);
    await repo.setRepeat(uid, '1,2,3,4,5,6,7');
    // Slot: today (Mon) 09:00, already past at now=10:00.
    await repo.setSchedule(
        uid, DateTime(2026, 6, 1, 9, 0).millisecondsSinceEpoch ~/ 1000);

    final advancedTo = await repo.complete(uid);
    expect(advancedTo, isNotNull);
    final t = await byUid(uid);
    expect(t.status, TaskStatus.open, reason: 'it moves, it does not finish');
    expect(
        DateTime.fromMillisecondsSinceEpoch(advancedTo! * 1000),
        DateTime(2026, 6, 2, 9, 0),
        reason: 'past the held slot, never onto it');
  });

  test('completing a plain task finishes it', () async {
    final uid = await repo.add('one-off');
    expect(await repo.complete(uid), isNull);
    final t = await byUid(uid);
    expect(t.status, TaskStatus.done);
    expect(t.completedTs, isNotNull);
  });

  test('a real slot move clears a snooze; a confirming write keeps it',
      () async {
    final uid = await repo.add('review');
    await repo.moveToQuadrant(uid, Quadrant.schedule);
    await repo.setSchedule(uid, 2000);
    // Simulate a snooze via the row (the reminder feature lands in M5).
    await (db.update(db.tasks)..where((t) => t.uid.equals(uid))).write(
        const TasksCompanion(remindSnoozedUntil: Value(1900)));

    await repo.setSchedule(uid, 2000); // confirming write
    expect((await byUid(uid)).remindSnoozedUntil, 1900);

    await repo.setSchedule(uid, 4000); // a real move
    expect((await byUid(uid)).remindSnoozedUntil, isNull);
  });

  test('roll-forward brings only stale repeats, one slot not a backlog',
      () async {
    final ritual = await repo.add('morning pages');
    await repo.moveToQuadrant(ritual, Quadrant.schedule);
    await repo.setRepeat(ritual, '1,2,3,4,5,6,7');
    await repo.setSchedule(ritual,
        DateTime(2026, 5, 25, 8, 0).millisecondsSinceEpoch ~/ 1000);

    final oneOff = await repo.add('past one-off');
    await repo.moveToQuadrant(oneOff, Quadrant.schedule);
    await repo.setSchedule(
        oneOff, DateTime(2026, 5, 25, 9, 0).millisecondsSinceEpoch ~/ 1000);

    now = DateTime(2026, 6, 1, 0, 30);
    expect(await repo.rollPastRepeats(), 1);
    expect(
        DateTime.fromMillisecondsSinceEpoch(
            (await byUid(ritual)).scheduledTs! * 1000),
        DateTime(2026, 6, 1, 8, 0));
    expect(
        DateTime.fromMillisecondsSinceEpoch(
            (await byUid(oneOff)).scheduledTs! * 1000),
        DateTime(2026, 5, 25, 9, 0),
        reason: 'a one-off in the past is the user\'s business');
  });

  test('areas: eight at most, case-insensitively unique, removal unlabels',
      () async {
    final uid = await repo.add('run');
    final health = await repo.addArea('Health');
    await repo.setArea(uid, health);
    expect(() => repo.addArea('health'), throwsStateError);
    for (var i = 0; i < 4; i++) {
      await repo.addArea('Area $i');
    }
    expect(() => repo.addArea('one too many'), throwsStateError);

    final wearing = await repo.removeArea(health);
    expect(wearing, [uid]);
    expect((await byUid(uid)).areaUid, isNull,
        reason: 'the task survives, unlabelled');
  });

  test('a deleted task keeps its repeat for undo', () async {
    final uid = await repo.add('habit');
    await repo.moveToQuadrant(uid, Quadrant.schedule);
    await repo.setRepeat(uid, '2,4');
    await repo.setStatus(uid, TaskStatus.deleted);
    await repo.setStatus(uid, TaskStatus.open);
    expect((await byUid(uid)).repeatDays, '2,4',
        reason: 'undo restores the habit intact');
  });
}
