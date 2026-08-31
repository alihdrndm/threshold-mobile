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

@DriftDatabase(tables: [Tasks, Areas, SettingsKV, GoogleEventMap, SyncState])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'threshold'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
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
        },
      );
}
