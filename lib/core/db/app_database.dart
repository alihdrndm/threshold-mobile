import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The local store, mirroring the desktop schema (through its migration v7)
/// plus the sync columns from HANDOFF §2.1. Migrations follow the desktop
/// discipline: numbered, transactional, tested — "a failure partway leaves
/// the schema changed and the version unbumped … an app that does not
/// start at all."
@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().unique()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  TextColumn get areaUid => text().nullable()();
  BoolColumn get urgent => boolean().nullable()();
  BoolColumn get important => boolean().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get createdTs => text()();
  TextColumn get completedTs => text().nullable()();
  IntColumn get scheduledTs => integer().nullable()();
  TextColumn get calendarEventId => text().nullable()();
  TextColumn get calendarHtmlLink => text().nullable()();
  TextColumn get repeatDays => text().nullable()();
  IntColumn get remindFiredForTs => integer().nullable()();
  IntColumn get remindSnoozedUntil => integer().nullable()();
  TextColumn get boardEventId => text().nullable()();
  IntColumn get legacyDesktopId => integer().nullable()();
  IntColumn get updatedTs => integer()();
}

@DataClassName('AreaRow')
class Areas extends Table {
  TextColumn get uid => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();
  IntColumn get updatedTs => integer()();

  @override
  Set<Column> get primaryKey => {uid};
}

class SettingsKV extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// The read model for events on the user's calendars — foreign events with
/// their titles (v1's upgrade over the desktop's anonymous busy stripes)
/// and the isThreshold marker for our own. Adoption fills adoptedTaskUid.
@DataClassName('GoogleEventRow')
class GoogleEventMap extends Table {
  TextColumn get eventId => text()();
  TextColumn get calendarId => text()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  IntColumn get startTs => integer().nullable()();
  IntColumn get endTs => integer().nullable()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  TextColumn get updated => text().withDefault(const Constant(''))();
  BoolColumn get isThreshold => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('confirmed'))();
  TextColumn get eventType => text().withDefault(const Constant('default'))();
  TextColumn get adoptedTaskUid => text().nullable()();

  @override
  Set<Column> get primaryKey => {eventId};
}

/// Per-calendar incremental-sync bookkeeping. Sync tokens are per-device
/// by design — there is no shared cursor to corrupt.
@DataClassName('SyncStateRow')
class SyncState extends Table {
  TextColumn get calendarId => text()();
  TextColumn get syncToken => text().nullable()();
  IntColumn get lastSyncTs => integer().nullable()();
  TextColumn get lastStatus => text().nullable()();

  @override
  Set<Column> get primaryKey => {calendarId};
}

/// The offline outbox: every calendar-affecting mutation queues here and a
/// serialized sync pass drains it. UI never waits on the network — "a task
/// move never waits on the calendar."
@DataClassName('PendingOpRow')
class PendingOps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get taskUid => text()();
  TextColumn get kind =>
      text()(); // schedule | patchTime | deleteEvent
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  IntColumn get createdTs => integer()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// The quote reservoir — user-added only, synced with the desktop's through
/// the board channel. Text is the identity (the desktop enforces the same:
/// "the same words twice is a mistake, not a preference").
@DataClassName('QuoteRow')
class Quotes extends Table {
  // Getter `body`, column `text`: a column named text would shadow the
  // builder inside this class; .named keeps SQL parity with the desktop.
  TextColumn get body => text().named('text')();
  TextColumn get author => text().nullable()();
  TextColumn get createdTs => text()();

  @override
  Set<Column> get primaryKey => {body};
}

/// An intention is append-only: "what you said at the start". Overwriting it
/// to hold a session's life would destroy the before/after pair that makes
/// recording a prediction worth anything.
@DataClassName('IntentionRow')
class Intentions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ts => text()();
  TextColumn get body => text().named('text').nullable()();
  TextColumn get ifThen => text().nullable()();
  IntColumn get predictedYes => integer().nullable()();
  IntColumn get durationMin => integer().nullable()();
  TextColumn get taskUid => text().nullable()();
  TextColumn get outcome =>
      text().nullable()(); // completed|skipped|drifted|browsing
}

/// A session has a life: it runs, it ends, and someone answers for it.
/// Timestamps are unix seconds — compared and subtracted, not read as text.
@DataClassName('SessionRow')
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get intentionId => integer()();
  TextColumn get taskUid => text().nullable()();
  // Snapshot, not a join: renaming or deleting the task later must not
  // rewrite what a past session was about.
  TextColumn get taskTitle => text().nullable()();
  IntColumn get startedTs => integer()();
  IntColumn get endsTs => integer()();
  IntColumn get durationMin => integer()();
  IntColumn get predictedYes => integer().nullable()();
  TextColumn get state => text().withDefault(const Constant('running'))();
  IntColumn get endedTs => integer().nullable()();
  IntColumn get answeredTs => integer().nullable()();
  IntColumn get taskDone => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [
  Tasks,
  Areas,
  SettingsKV,
  GoogleEventMap,
  SyncState,
  PendingOps,
  Quotes,
  Intentions,
  Sessions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'threshold'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_sessions_one_running '
              "ON sessions(state) WHERE state = 'running'");
          // Seeded areas, like desktop's migration v2: "Contexts are data,
          // not code."
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          for (final (i, name) in ['Job', 'Personal', 'Side'].indexed) {
            await into(areas).insert(AreasCompanion.insert(
              uid: 'seed-$name'.toLowerCase(),
              name: name,
              sortOrder: i,
              updatedTs: now,
            ));
          }
        },
        onUpgrade: (m, from, to) async {
          // v2: the calendar read model + per-calendar sync bookkeeping.
          if (from < 2) {
            await m.createTable(googleEventMap);
            await m.createTable(syncState);
          }
          // v3: the offline outbox.
          if (from < 3) {
            await m.createTable(pendingOps);
          }
          // v4: the ritual's furniture — the quote reservoir, append-only
          // intentions, and sessions. At most one session may run: two is a
          // bug, and an insert that fails loudly beats two check-ins.
          if (from < 4) {
            await m.createTable(quotes);
            await m.createTable(intentions);
            await m.createTable(sessions);
            await customStatement(
                'CREATE UNIQUE INDEX IF NOT EXISTS idx_sessions_one_running '
                "ON sessions(state) WHERE state = 'running'");
          }
        },
      );
}
