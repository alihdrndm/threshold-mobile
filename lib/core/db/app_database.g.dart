// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaUidMeta = const VerificationMeta(
    'areaUid',
  );
  @override
  late final GeneratedColumn<String> areaUid = GeneratedColumn<String>(
    'area_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urgentMeta = const VerificationMeta('urgent');
  @override
  late final GeneratedColumn<bool> urgent = GeneratedColumn<bool>(
    'urgent',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("urgent" IN (0, 1))',
    ),
  );
  static const VerificationMeta _importantMeta = const VerificationMeta(
    'important',
  );
  @override
  late final GeneratedColumn<bool> important = GeneratedColumn<bool>(
    'important',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("important" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _createdTsMeta = const VerificationMeta(
    'createdTs',
  );
  @override
  late final GeneratedColumn<String> createdTs = GeneratedColumn<String>(
    'created_ts',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedTsMeta = const VerificationMeta(
    'completedTs',
  );
  @override
  late final GeneratedColumn<String> completedTs = GeneratedColumn<String>(
    'completed_ts',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledTsMeta = const VerificationMeta(
    'scheduledTs',
  );
  @override
  late final GeneratedColumn<int> scheduledTs = GeneratedColumn<int>(
    'scheduled_ts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calendarEventIdMeta = const VerificationMeta(
    'calendarEventId',
  );
  @override
  late final GeneratedColumn<String> calendarEventId = GeneratedColumn<String>(
    'calendar_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calendarHtmlLinkMeta = const VerificationMeta(
    'calendarHtmlLink',
  );
  @override
  late final GeneratedColumn<String> calendarHtmlLink = GeneratedColumn<String>(
    'calendar_html_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatDaysMeta = const VerificationMeta(
    'repeatDays',
  );
  @override
  late final GeneratedColumn<String> repeatDays = GeneratedColumn<String>(
    'repeat_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindFiredForTsMeta = const VerificationMeta(
    'remindFiredForTs',
  );
  @override
  late final GeneratedColumn<int> remindFiredForTs = GeneratedColumn<int>(
    'remind_fired_for_ts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindSnoozedUntilMeta =
      const VerificationMeta('remindSnoozedUntil');
  @override
  late final GeneratedColumn<int> remindSnoozedUntil = GeneratedColumn<int>(
    'remind_snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boardEventIdMeta = const VerificationMeta(
    'boardEventId',
  );
  @override
  late final GeneratedColumn<String> boardEventId = GeneratedColumn<String>(
    'board_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legacyDesktopIdMeta = const VerificationMeta(
    'legacyDesktopId',
  );
  @override
  late final GeneratedColumn<int> legacyDesktopId = GeneratedColumn<int>(
    'legacy_desktop_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedTsMeta = const VerificationMeta(
    'updatedTs',
  );
  @override
  late final GeneratedColumn<int> updatedTs = GeneratedColumn<int>(
    'updated_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uid,
    title,
    note,
    areaUid,
    urgent,
    important,
    sortOrder,
    status,
    createdTs,
    completedTs,
    scheduledTs,
    calendarEventId,
    calendarHtmlLink,
    repeatDays,
    remindFiredForTs,
    remindSnoozedUntil,
    boardEventId,
    legacyDesktopId,
    updatedTs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('area_uid')) {
      context.handle(
        _areaUidMeta,
        areaUid.isAcceptableOrUnknown(data['area_uid']!, _areaUidMeta),
      );
    }
    if (data.containsKey('urgent')) {
      context.handle(
        _urgentMeta,
        urgent.isAcceptableOrUnknown(data['urgent']!, _urgentMeta),
      );
    }
    if (data.containsKey('important')) {
      context.handle(
        _importantMeta,
        important.isAcceptableOrUnknown(data['important']!, _importantMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_ts')) {
      context.handle(
        _createdTsMeta,
        createdTs.isAcceptableOrUnknown(data['created_ts']!, _createdTsMeta),
      );
    } else if (isInserting) {
      context.missing(_createdTsMeta);
    }
    if (data.containsKey('completed_ts')) {
      context.handle(
        _completedTsMeta,
        completedTs.isAcceptableOrUnknown(
          data['completed_ts']!,
          _completedTsMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_ts')) {
      context.handle(
        _scheduledTsMeta,
        scheduledTs.isAcceptableOrUnknown(
          data['scheduled_ts']!,
          _scheduledTsMeta,
        ),
      );
    }
    if (data.containsKey('calendar_event_id')) {
      context.handle(
        _calendarEventIdMeta,
        calendarEventId.isAcceptableOrUnknown(
          data['calendar_event_id']!,
          _calendarEventIdMeta,
        ),
      );
    }
    if (data.containsKey('calendar_html_link')) {
      context.handle(
        _calendarHtmlLinkMeta,
        calendarHtmlLink.isAcceptableOrUnknown(
          data['calendar_html_link']!,
          _calendarHtmlLinkMeta,
        ),
      );
    }
    if (data.containsKey('repeat_days')) {
      context.handle(
        _repeatDaysMeta,
        repeatDays.isAcceptableOrUnknown(data['repeat_days']!, _repeatDaysMeta),
      );
    }
    if (data.containsKey('remind_fired_for_ts')) {
      context.handle(
        _remindFiredForTsMeta,
        remindFiredForTs.isAcceptableOrUnknown(
          data['remind_fired_for_ts']!,
          _remindFiredForTsMeta,
        ),
      );
    }
    if (data.containsKey('remind_snoozed_until')) {
      context.handle(
        _remindSnoozedUntilMeta,
        remindSnoozedUntil.isAcceptableOrUnknown(
          data['remind_snoozed_until']!,
          _remindSnoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('board_event_id')) {
      context.handle(
        _boardEventIdMeta,
        boardEventId.isAcceptableOrUnknown(
          data['board_event_id']!,
          _boardEventIdMeta,
        ),
      );
    }
    if (data.containsKey('legacy_desktop_id')) {
      context.handle(
        _legacyDesktopIdMeta,
        legacyDesktopId.isAcceptableOrUnknown(
          data['legacy_desktop_id']!,
          _legacyDesktopIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_ts')) {
      context.handle(
        _updatedTsMeta,
        updatedTs.isAcceptableOrUnknown(data['updated_ts']!, _updatedTsMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedTsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      areaUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_uid'],
      ),
      urgent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}urgent'],
      ),
      important: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}important'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdTs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_ts'],
      )!,
      completedTs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_ts'],
      ),
      scheduledTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_ts'],
      ),
      calendarEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_event_id'],
      ),
      calendarHtmlLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_html_link'],
      ),
      repeatDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_days'],
      ),
      remindFiredForTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remind_fired_for_ts'],
      ),
      remindSnoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remind_snoozed_until'],
      ),
      boardEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_event_id'],
      ),
      legacyDesktopId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}legacy_desktop_id'],
      ),
      updatedTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_ts'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final int id;
  final String uid;
  final String title;
  final String? note;
  final String? areaUid;
  final bool? urgent;
  final bool? important;
  final int sortOrder;
  final String status;
  final String createdTs;
  final String? completedTs;
  final int? scheduledTs;
  final String? calendarEventId;
  final String? calendarHtmlLink;
  final String? repeatDays;
  final int? remindFiredForTs;
  final int? remindSnoozedUntil;
  final String? boardEventId;
  final int? legacyDesktopId;
  final int updatedTs;
  const TaskRow({
    required this.id,
    required this.uid,
    required this.title,
    this.note,
    this.areaUid,
    this.urgent,
    this.important,
    required this.sortOrder,
    required this.status,
    required this.createdTs,
    this.completedTs,
    this.scheduledTs,
    this.calendarEventId,
    this.calendarHtmlLink,
    this.repeatDays,
    this.remindFiredForTs,
    this.remindSnoozedUntil,
    this.boardEventId,
    this.legacyDesktopId,
    required this.updatedTs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || areaUid != null) {
      map['area_uid'] = Variable<String>(areaUid);
    }
    if (!nullToAbsent || urgent != null) {
      map['urgent'] = Variable<bool>(urgent);
    }
    if (!nullToAbsent || important != null) {
      map['important'] = Variable<bool>(important);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['status'] = Variable<String>(status);
    map['created_ts'] = Variable<String>(createdTs);
    if (!nullToAbsent || completedTs != null) {
      map['completed_ts'] = Variable<String>(completedTs);
    }
    if (!nullToAbsent || scheduledTs != null) {
      map['scheduled_ts'] = Variable<int>(scheduledTs);
    }
    if (!nullToAbsent || calendarEventId != null) {
      map['calendar_event_id'] = Variable<String>(calendarEventId);
    }
    if (!nullToAbsent || calendarHtmlLink != null) {
      map['calendar_html_link'] = Variable<String>(calendarHtmlLink);
    }
    if (!nullToAbsent || repeatDays != null) {
      map['repeat_days'] = Variable<String>(repeatDays);
    }
    if (!nullToAbsent || remindFiredForTs != null) {
      map['remind_fired_for_ts'] = Variable<int>(remindFiredForTs);
    }
    if (!nullToAbsent || remindSnoozedUntil != null) {
      map['remind_snoozed_until'] = Variable<int>(remindSnoozedUntil);
    }
    if (!nullToAbsent || boardEventId != null) {
      map['board_event_id'] = Variable<String>(boardEventId);
    }
    if (!nullToAbsent || legacyDesktopId != null) {
      map['legacy_desktop_id'] = Variable<int>(legacyDesktopId);
    }
    map['updated_ts'] = Variable<int>(updatedTs);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      uid: Value(uid),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      areaUid: areaUid == null && nullToAbsent
          ? const Value.absent()
          : Value(areaUid),
      urgent: urgent == null && nullToAbsent
          ? const Value.absent()
          : Value(urgent),
      important: important == null && nullToAbsent
          ? const Value.absent()
          : Value(important),
      sortOrder: Value(sortOrder),
      status: Value(status),
      createdTs: Value(createdTs),
      completedTs: completedTs == null && nullToAbsent
          ? const Value.absent()
          : Value(completedTs),
      scheduledTs: scheduledTs == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledTs),
      calendarEventId: calendarEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarEventId),
      calendarHtmlLink: calendarHtmlLink == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarHtmlLink),
      repeatDays: repeatDays == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatDays),
      remindFiredForTs: remindFiredForTs == null && nullToAbsent
          ? const Value.absent()
          : Value(remindFiredForTs),
      remindSnoozedUntil: remindSnoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(remindSnoozedUntil),
      boardEventId: boardEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(boardEventId),
      legacyDesktopId: legacyDesktopId == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyDesktopId),
      updatedTs: Value(updatedTs),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      areaUid: serializer.fromJson<String?>(json['areaUid']),
      urgent: serializer.fromJson<bool?>(json['urgent']),
      important: serializer.fromJson<bool?>(json['important']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      status: serializer.fromJson<String>(json['status']),
      createdTs: serializer.fromJson<String>(json['createdTs']),
      completedTs: serializer.fromJson<String?>(json['completedTs']),
      scheduledTs: serializer.fromJson<int?>(json['scheduledTs']),
      calendarEventId: serializer.fromJson<String?>(json['calendarEventId']),
      calendarHtmlLink: serializer.fromJson<String?>(json['calendarHtmlLink']),
      repeatDays: serializer.fromJson<String?>(json['repeatDays']),
      remindFiredForTs: serializer.fromJson<int?>(json['remindFiredForTs']),
      remindSnoozedUntil: serializer.fromJson<int?>(json['remindSnoozedUntil']),
      boardEventId: serializer.fromJson<String?>(json['boardEventId']),
      legacyDesktopId: serializer.fromJson<int?>(json['legacyDesktopId']),
      updatedTs: serializer.fromJson<int>(json['updatedTs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'areaUid': serializer.toJson<String?>(areaUid),
      'urgent': serializer.toJson<bool?>(urgent),
      'important': serializer.toJson<bool?>(important),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'status': serializer.toJson<String>(status),
      'createdTs': serializer.toJson<String>(createdTs),
      'completedTs': serializer.toJson<String?>(completedTs),
      'scheduledTs': serializer.toJson<int?>(scheduledTs),
      'calendarEventId': serializer.toJson<String?>(calendarEventId),
      'calendarHtmlLink': serializer.toJson<String?>(calendarHtmlLink),
      'repeatDays': serializer.toJson<String?>(repeatDays),
      'remindFiredForTs': serializer.toJson<int?>(remindFiredForTs),
      'remindSnoozedUntil': serializer.toJson<int?>(remindSnoozedUntil),
      'boardEventId': serializer.toJson<String?>(boardEventId),
      'legacyDesktopId': serializer.toJson<int?>(legacyDesktopId),
      'updatedTs': serializer.toJson<int>(updatedTs),
    };
  }

  TaskRow copyWith({
    int? id,
    String? uid,
    String? title,
    Value<String?> note = const Value.absent(),
    Value<String?> areaUid = const Value.absent(),
    Value<bool?> urgent = const Value.absent(),
    Value<bool?> important = const Value.absent(),
    int? sortOrder,
    String? status,
    String? createdTs,
    Value<String?> completedTs = const Value.absent(),
    Value<int?> scheduledTs = const Value.absent(),
    Value<String?> calendarEventId = const Value.absent(),
    Value<String?> calendarHtmlLink = const Value.absent(),
    Value<String?> repeatDays = const Value.absent(),
    Value<int?> remindFiredForTs = const Value.absent(),
    Value<int?> remindSnoozedUntil = const Value.absent(),
    Value<String?> boardEventId = const Value.absent(),
    Value<int?> legacyDesktopId = const Value.absent(),
    int? updatedTs,
  }) => TaskRow(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    areaUid: areaUid.present ? areaUid.value : this.areaUid,
    urgent: urgent.present ? urgent.value : this.urgent,
    important: important.present ? important.value : this.important,
    sortOrder: sortOrder ?? this.sortOrder,
    status: status ?? this.status,
    createdTs: createdTs ?? this.createdTs,
    completedTs: completedTs.present ? completedTs.value : this.completedTs,
    scheduledTs: scheduledTs.present ? scheduledTs.value : this.scheduledTs,
    calendarEventId: calendarEventId.present
        ? calendarEventId.value
        : this.calendarEventId,
    calendarHtmlLink: calendarHtmlLink.present
        ? calendarHtmlLink.value
        : this.calendarHtmlLink,
    repeatDays: repeatDays.present ? repeatDays.value : this.repeatDays,
    remindFiredForTs: remindFiredForTs.present
        ? remindFiredForTs.value
        : this.remindFiredForTs,
    remindSnoozedUntil: remindSnoozedUntil.present
        ? remindSnoozedUntil.value
        : this.remindSnoozedUntil,
    boardEventId: boardEventId.present ? boardEventId.value : this.boardEventId,
    legacyDesktopId: legacyDesktopId.present
        ? legacyDesktopId.value
        : this.legacyDesktopId,
    updatedTs: updatedTs ?? this.updatedTs,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      areaUid: data.areaUid.present ? data.areaUid.value : this.areaUid,
      urgent: data.urgent.present ? data.urgent.value : this.urgent,
      important: data.important.present ? data.important.value : this.important,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      status: data.status.present ? data.status.value : this.status,
      createdTs: data.createdTs.present ? data.createdTs.value : this.createdTs,
      completedTs: data.completedTs.present
          ? data.completedTs.value
          : this.completedTs,
      scheduledTs: data.scheduledTs.present
          ? data.scheduledTs.value
          : this.scheduledTs,
      calendarEventId: data.calendarEventId.present
          ? data.calendarEventId.value
          : this.calendarEventId,
      calendarHtmlLink: data.calendarHtmlLink.present
          ? data.calendarHtmlLink.value
          : this.calendarHtmlLink,
      repeatDays: data.repeatDays.present
          ? data.repeatDays.value
          : this.repeatDays,
      remindFiredForTs: data.remindFiredForTs.present
          ? data.remindFiredForTs.value
          : this.remindFiredForTs,
      remindSnoozedUntil: data.remindSnoozedUntil.present
          ? data.remindSnoozedUntil.value
          : this.remindSnoozedUntil,
      boardEventId: data.boardEventId.present
          ? data.boardEventId.value
          : this.boardEventId,
      legacyDesktopId: data.legacyDesktopId.present
          ? data.legacyDesktopId.value
          : this.legacyDesktopId,
      updatedTs: data.updatedTs.present ? data.updatedTs.value : this.updatedTs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('areaUid: $areaUid, ')
          ..write('urgent: $urgent, ')
          ..write('important: $important, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('createdTs: $createdTs, ')
          ..write('completedTs: $completedTs, ')
          ..write('scheduledTs: $scheduledTs, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('calendarHtmlLink: $calendarHtmlLink, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('remindFiredForTs: $remindFiredForTs, ')
          ..write('remindSnoozedUntil: $remindSnoozedUntil, ')
          ..write('boardEventId: $boardEventId, ')
          ..write('legacyDesktopId: $legacyDesktopId, ')
          ..write('updatedTs: $updatedTs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uid,
    title,
    note,
    areaUid,
    urgent,
    important,
    sortOrder,
    status,
    createdTs,
    completedTs,
    scheduledTs,
    calendarEventId,
    calendarHtmlLink,
    repeatDays,
    remindFiredForTs,
    remindSnoozedUntil,
    boardEventId,
    legacyDesktopId,
    updatedTs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.title == this.title &&
          other.note == this.note &&
          other.areaUid == this.areaUid &&
          other.urgent == this.urgent &&
          other.important == this.important &&
          other.sortOrder == this.sortOrder &&
          other.status == this.status &&
          other.createdTs == this.createdTs &&
          other.completedTs == this.completedTs &&
          other.scheduledTs == this.scheduledTs &&
          other.calendarEventId == this.calendarEventId &&
          other.calendarHtmlLink == this.calendarHtmlLink &&
          other.repeatDays == this.repeatDays &&
          other.remindFiredForTs == this.remindFiredForTs &&
          other.remindSnoozedUntil == this.remindSnoozedUntil &&
          other.boardEventId == this.boardEventId &&
          other.legacyDesktopId == this.legacyDesktopId &&
          other.updatedTs == this.updatedTs);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> title;
  final Value<String?> note;
  final Value<String?> areaUid;
  final Value<bool?> urgent;
  final Value<bool?> important;
  final Value<int> sortOrder;
  final Value<String> status;
  final Value<String> createdTs;
  final Value<String?> completedTs;
  final Value<int?> scheduledTs;
  final Value<String?> calendarEventId;
  final Value<String?> calendarHtmlLink;
  final Value<String?> repeatDays;
  final Value<int?> remindFiredForTs;
  final Value<int?> remindSnoozedUntil;
  final Value<String?> boardEventId;
  final Value<int?> legacyDesktopId;
  final Value<int> updatedTs;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.areaUid = const Value.absent(),
    this.urgent = const Value.absent(),
    this.important = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.status = const Value.absent(),
    this.createdTs = const Value.absent(),
    this.completedTs = const Value.absent(),
    this.scheduledTs = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.calendarHtmlLink = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.remindFiredForTs = const Value.absent(),
    this.remindSnoozedUntil = const Value.absent(),
    this.boardEventId = const Value.absent(),
    this.legacyDesktopId = const Value.absent(),
    this.updatedTs = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    required String title,
    this.note = const Value.absent(),
    this.areaUid = const Value.absent(),
    this.urgent = const Value.absent(),
    this.important = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.status = const Value.absent(),
    required String createdTs,
    this.completedTs = const Value.absent(),
    this.scheduledTs = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.calendarHtmlLink = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.remindFiredForTs = const Value.absent(),
    this.remindSnoozedUntil = const Value.absent(),
    this.boardEventId = const Value.absent(),
    this.legacyDesktopId = const Value.absent(),
    required int updatedTs,
  }) : uid = Value(uid),
       title = Value(title),
       createdTs = Value(createdTs),
       updatedTs = Value(updatedTs);
  static Insertable<TaskRow> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? areaUid,
    Expression<bool>? urgent,
    Expression<bool>? important,
    Expression<int>? sortOrder,
    Expression<String>? status,
    Expression<String>? createdTs,
    Expression<String>? completedTs,
    Expression<int>? scheduledTs,
    Expression<String>? calendarEventId,
    Expression<String>? calendarHtmlLink,
    Expression<String>? repeatDays,
    Expression<int>? remindFiredForTs,
    Expression<int>? remindSnoozedUntil,
    Expression<String>? boardEventId,
    Expression<int>? legacyDesktopId,
    Expression<int>? updatedTs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (areaUid != null) 'area_uid': areaUid,
      if (urgent != null) 'urgent': urgent,
      if (important != null) 'important': important,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (status != null) 'status': status,
      if (createdTs != null) 'created_ts': createdTs,
      if (completedTs != null) 'completed_ts': completedTs,
      if (scheduledTs != null) 'scheduled_ts': scheduledTs,
      if (calendarEventId != null) 'calendar_event_id': calendarEventId,
      if (calendarHtmlLink != null) 'calendar_html_link': calendarHtmlLink,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (remindFiredForTs != null) 'remind_fired_for_ts': remindFiredForTs,
      if (remindSnoozedUntil != null)
        'remind_snoozed_until': remindSnoozedUntil,
      if (boardEventId != null) 'board_event_id': boardEventId,
      if (legacyDesktopId != null) 'legacy_desktop_id': legacyDesktopId,
      if (updatedTs != null) 'updated_ts': updatedTs,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<String>? title,
    Value<String?>? note,
    Value<String?>? areaUid,
    Value<bool?>? urgent,
    Value<bool?>? important,
    Value<int>? sortOrder,
    Value<String>? status,
    Value<String>? createdTs,
    Value<String?>? completedTs,
    Value<int?>? scheduledTs,
    Value<String?>? calendarEventId,
    Value<String?>? calendarHtmlLink,
    Value<String?>? repeatDays,
    Value<int?>? remindFiredForTs,
    Value<int?>? remindSnoozedUntil,
    Value<String?>? boardEventId,
    Value<int?>? legacyDesktopId,
    Value<int>? updatedTs,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      note: note ?? this.note,
      areaUid: areaUid ?? this.areaUid,
      urgent: urgent ?? this.urgent,
      important: important ?? this.important,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      createdTs: createdTs ?? this.createdTs,
      completedTs: completedTs ?? this.completedTs,
      scheduledTs: scheduledTs ?? this.scheduledTs,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      calendarHtmlLink: calendarHtmlLink ?? this.calendarHtmlLink,
      repeatDays: repeatDays ?? this.repeatDays,
      remindFiredForTs: remindFiredForTs ?? this.remindFiredForTs,
      remindSnoozedUntil: remindSnoozedUntil ?? this.remindSnoozedUntil,
      boardEventId: boardEventId ?? this.boardEventId,
      legacyDesktopId: legacyDesktopId ?? this.legacyDesktopId,
      updatedTs: updatedTs ?? this.updatedTs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (areaUid.present) {
      map['area_uid'] = Variable<String>(areaUid.value);
    }
    if (urgent.present) {
      map['urgent'] = Variable<bool>(urgent.value);
    }
    if (important.present) {
      map['important'] = Variable<bool>(important.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdTs.present) {
      map['created_ts'] = Variable<String>(createdTs.value);
    }
    if (completedTs.present) {
      map['completed_ts'] = Variable<String>(completedTs.value);
    }
    if (scheduledTs.present) {
      map['scheduled_ts'] = Variable<int>(scheduledTs.value);
    }
    if (calendarEventId.present) {
      map['calendar_event_id'] = Variable<String>(calendarEventId.value);
    }
    if (calendarHtmlLink.present) {
      map['calendar_html_link'] = Variable<String>(calendarHtmlLink.value);
    }
    if (repeatDays.present) {
      map['repeat_days'] = Variable<String>(repeatDays.value);
    }
    if (remindFiredForTs.present) {
      map['remind_fired_for_ts'] = Variable<int>(remindFiredForTs.value);
    }
    if (remindSnoozedUntil.present) {
      map['remind_snoozed_until'] = Variable<int>(remindSnoozedUntil.value);
    }
    if (boardEventId.present) {
      map['board_event_id'] = Variable<String>(boardEventId.value);
    }
    if (legacyDesktopId.present) {
      map['legacy_desktop_id'] = Variable<int>(legacyDesktopId.value);
    }
    if (updatedTs.present) {
      map['updated_ts'] = Variable<int>(updatedTs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('areaUid: $areaUid, ')
          ..write('urgent: $urgent, ')
          ..write('important: $important, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('createdTs: $createdTs, ')
          ..write('completedTs: $completedTs, ')
          ..write('scheduledTs: $scheduledTs, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('calendarHtmlLink: $calendarHtmlLink, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('remindFiredForTs: $remindFiredForTs, ')
          ..write('remindSnoozedUntil: $remindSnoozedUntil, ')
          ..write('boardEventId: $boardEventId, ')
          ..write('legacyDesktopId: $legacyDesktopId, ')
          ..write('updatedTs: $updatedTs')
          ..write(')'))
        .toString();
  }
}

class $AreasTable extends Areas with TableInfo<$AreasTable, AreaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedTsMeta = const VerificationMeta(
    'updatedTs',
  );
  @override
  late final GeneratedColumn<int> updatedTs = GeneratedColumn<int>(
    'updated_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [uid, name, sortOrder, updatedTs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'areas';
  @override
  VerificationContext validateIntegrity(
    Insertable<AreaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('updated_ts')) {
      context.handle(
        _updatedTsMeta,
        updatedTs.isAcceptableOrUnknown(data['updated_ts']!, _updatedTsMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedTsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  AreaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AreaRow(
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_ts'],
      )!,
    );
  }

  @override
  $AreasTable createAlias(String alias) {
    return $AreasTable(attachedDatabase, alias);
  }
}

class AreaRow extends DataClass implements Insertable<AreaRow> {
  final String uid;
  final String name;
  final int sortOrder;
  final int updatedTs;
  const AreaRow({
    required this.uid,
    required this.name,
    required this.sortOrder,
    required this.updatedTs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_ts'] = Variable<int>(updatedTs);
    return map;
  }

  AreasCompanion toCompanion(bool nullToAbsent) {
    return AreasCompanion(
      uid: Value(uid),
      name: Value(name),
      sortOrder: Value(sortOrder),
      updatedTs: Value(updatedTs),
    );
  }

  factory AreaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AreaRow(
      uid: serializer.fromJson<String>(json['uid']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedTs: serializer.fromJson<int>(json['updatedTs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedTs': serializer.toJson<int>(updatedTs),
    };
  }

  AreaRow copyWith({
    String? uid,
    String? name,
    int? sortOrder,
    int? updatedTs,
  }) => AreaRow(
    uid: uid ?? this.uid,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedTs: updatedTs ?? this.updatedTs,
  );
  AreaRow copyWithCompanion(AreasCompanion data) {
    return AreaRow(
      uid: data.uid.present ? data.uid.value : this.uid,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedTs: data.updatedTs.present ? data.updatedTs.value : this.updatedTs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AreaRow(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedTs: $updatedTs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, name, sortOrder, updatedTs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AreaRow &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.updatedTs == this.updatedTs);
}

class AreasCompanion extends UpdateCompanion<AreaRow> {
  final Value<String> uid;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> updatedTs;
  final Value<int> rowid;
  const AreasCompanion({
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedTs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AreasCompanion.insert({
    required String uid,
    required String name,
    required int sortOrder,
    required int updatedTs,
    this.rowid = const Value.absent(),
  }) : uid = Value(uid),
       name = Value(name),
       sortOrder = Value(sortOrder),
       updatedTs = Value(updatedTs);
  static Insertable<AreaRow> custom({
    Expression<String>? uid,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? updatedTs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedTs != null) 'updated_ts': updatedTs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AreasCompanion copyWith({
    Value<String>? uid,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<int>? updatedTs,
    Value<int>? rowid,
  }) {
    return AreasCompanion(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedTs: updatedTs ?? this.updatedTs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedTs.present) {
      map['updated_ts'] = Variable<int>(updatedTs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AreasCompanion(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedTs: $updatedTs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsKVTable extends SettingsKV
    with TableInfo<$SettingsKVTable, SettingsKVData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsKVTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_k_v';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsKVData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsKVData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsKVData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsKVTable createAlias(String alias) {
    return $SettingsKVTable(attachedDatabase, alias);
  }
}

class SettingsKVData extends DataClass implements Insertable<SettingsKVData> {
  final String key;
  final String value;
  const SettingsKVData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsKVCompanion toCompanion(bool nullToAbsent) {
    return SettingsKVCompanion(key: Value(key), value: Value(value));
  }

  factory SettingsKVData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsKVData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingsKVData copyWith({String? key, String? value}) =>
      SettingsKVData(key: key ?? this.key, value: value ?? this.value);
  SettingsKVData copyWithCompanion(SettingsKVCompanion data) {
    return SettingsKVData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsKVData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsKVData &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsKVCompanion extends UpdateCompanion<SettingsKVData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsKVCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsKVCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingsKVData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsKVCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsKVCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsKVCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoogleEventMapTable extends GoogleEventMap
    with TableInfo<$GoogleEventMapTable, GoogleEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoogleEventMapTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calendarIdMeta = const VerificationMeta(
    'calendarId',
  );
  @override
  late final GeneratedColumn<String> calendarId = GeneratedColumn<String>(
    'calendar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startTsMeta = const VerificationMeta(
    'startTs',
  );
  @override
  late final GeneratedColumn<int> startTs = GeneratedColumn<int>(
    'start_ts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTsMeta = const VerificationMeta('endTs');
  @override
  late final GeneratedColumn<int> endTs = GeneratedColumn<int>(
    'end_ts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAllDayMeta = const VerificationMeta(
    'isAllDay',
  );
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
    'is_all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedMeta = const VerificationMeta(
    'updated',
  );
  @override
  late final GeneratedColumn<String> updated = GeneratedColumn<String>(
    'updated',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isThresholdMeta = const VerificationMeta(
    'isThreshold',
  );
  @override
  late final GeneratedColumn<bool> isThreshold = GeneratedColumn<bool>(
    'is_threshold',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_threshold" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _adoptedTaskUidMeta = const VerificationMeta(
    'adoptedTaskUid',
  );
  @override
  late final GeneratedColumn<String> adoptedTaskUid = GeneratedColumn<String>(
    'adopted_task_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    calendarId,
    summary,
    startTs,
    endTs,
    isAllDay,
    updated,
    isThreshold,
    status,
    eventType,
    adoptedTaskUid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'google_event_map';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoogleEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('calendar_id')) {
      context.handle(
        _calendarIdMeta,
        calendarId.isAcceptableOrUnknown(data['calendar_id']!, _calendarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_calendarIdMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('start_ts')) {
      context.handle(
        _startTsMeta,
        startTs.isAcceptableOrUnknown(data['start_ts']!, _startTsMeta),
      );
    }
    if (data.containsKey('end_ts')) {
      context.handle(
        _endTsMeta,
        endTs.isAcceptableOrUnknown(data['end_ts']!, _endTsMeta),
      );
    }
    if (data.containsKey('is_all_day')) {
      context.handle(
        _isAllDayMeta,
        isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta),
      );
    }
    if (data.containsKey('updated')) {
      context.handle(
        _updatedMeta,
        updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta),
      );
    }
    if (data.containsKey('is_threshold')) {
      context.handle(
        _isThresholdMeta,
        isThreshold.isAcceptableOrUnknown(
          data['is_threshold']!,
          _isThresholdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    }
    if (data.containsKey('adopted_task_uid')) {
      context.handle(
        _adoptedTaskUidMeta,
        adoptedTaskUid.isAcceptableOrUnknown(
          data['adopted_task_uid']!,
          _adoptedTaskUidMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  GoogleEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoogleEventRow(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      calendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_id'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      startTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ts'],
      ),
      endTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ts'],
      ),
      isAllDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_all_day'],
      )!,
      updated: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated'],
      )!,
      isThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_threshold'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      adoptedTaskUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adopted_task_uid'],
      ),
    );
  }

  @override
  $GoogleEventMapTable createAlias(String alias) {
    return $GoogleEventMapTable(attachedDatabase, alias);
  }
}

class GoogleEventRow extends DataClass implements Insertable<GoogleEventRow> {
  final String eventId;
  final String calendarId;
  final String summary;
  final int? startTs;
  final int? endTs;
  final bool isAllDay;
  final String updated;
  final bool isThreshold;
  final String status;
  final String eventType;
  final String? adoptedTaskUid;
  const GoogleEventRow({
    required this.eventId,
    required this.calendarId,
    required this.summary,
    this.startTs,
    this.endTs,
    required this.isAllDay,
    required this.updated,
    required this.isThreshold,
    required this.status,
    required this.eventType,
    this.adoptedTaskUid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['calendar_id'] = Variable<String>(calendarId);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || startTs != null) {
      map['start_ts'] = Variable<int>(startTs);
    }
    if (!nullToAbsent || endTs != null) {
      map['end_ts'] = Variable<int>(endTs);
    }
    map['is_all_day'] = Variable<bool>(isAllDay);
    map['updated'] = Variable<String>(updated);
    map['is_threshold'] = Variable<bool>(isThreshold);
    map['status'] = Variable<String>(status);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || adoptedTaskUid != null) {
      map['adopted_task_uid'] = Variable<String>(adoptedTaskUid);
    }
    return map;
  }

  GoogleEventMapCompanion toCompanion(bool nullToAbsent) {
    return GoogleEventMapCompanion(
      eventId: Value(eventId),
      calendarId: Value(calendarId),
      summary: Value(summary),
      startTs: startTs == null && nullToAbsent
          ? const Value.absent()
          : Value(startTs),
      endTs: endTs == null && nullToAbsent
          ? const Value.absent()
          : Value(endTs),
      isAllDay: Value(isAllDay),
      updated: Value(updated),
      isThreshold: Value(isThreshold),
      status: Value(status),
      eventType: Value(eventType),
      adoptedTaskUid: adoptedTaskUid == null && nullToAbsent
          ? const Value.absent()
          : Value(adoptedTaskUid),
    );
  }

  factory GoogleEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoogleEventRow(
      eventId: serializer.fromJson<String>(json['eventId']),
      calendarId: serializer.fromJson<String>(json['calendarId']),
      summary: serializer.fromJson<String>(json['summary']),
      startTs: serializer.fromJson<int?>(json['startTs']),
      endTs: serializer.fromJson<int?>(json['endTs']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      updated: serializer.fromJson<String>(json['updated']),
      isThreshold: serializer.fromJson<bool>(json['isThreshold']),
      status: serializer.fromJson<String>(json['status']),
      eventType: serializer.fromJson<String>(json['eventType']),
      adoptedTaskUid: serializer.fromJson<String?>(json['adoptedTaskUid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'calendarId': serializer.toJson<String>(calendarId),
      'summary': serializer.toJson<String>(summary),
      'startTs': serializer.toJson<int?>(startTs),
      'endTs': serializer.toJson<int?>(endTs),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'updated': serializer.toJson<String>(updated),
      'isThreshold': serializer.toJson<bool>(isThreshold),
      'status': serializer.toJson<String>(status),
      'eventType': serializer.toJson<String>(eventType),
      'adoptedTaskUid': serializer.toJson<String?>(adoptedTaskUid),
    };
  }

  GoogleEventRow copyWith({
    String? eventId,
    String? calendarId,
    String? summary,
    Value<int?> startTs = const Value.absent(),
    Value<int?> endTs = const Value.absent(),
    bool? isAllDay,
    String? updated,
    bool? isThreshold,
    String? status,
    String? eventType,
    Value<String?> adoptedTaskUid = const Value.absent(),
  }) => GoogleEventRow(
    eventId: eventId ?? this.eventId,
    calendarId: calendarId ?? this.calendarId,
    summary: summary ?? this.summary,
    startTs: startTs.present ? startTs.value : this.startTs,
    endTs: endTs.present ? endTs.value : this.endTs,
    isAllDay: isAllDay ?? this.isAllDay,
    updated: updated ?? this.updated,
    isThreshold: isThreshold ?? this.isThreshold,
    status: status ?? this.status,
    eventType: eventType ?? this.eventType,
    adoptedTaskUid: adoptedTaskUid.present
        ? adoptedTaskUid.value
        : this.adoptedTaskUid,
  );
  GoogleEventRow copyWithCompanion(GoogleEventMapCompanion data) {
    return GoogleEventRow(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      calendarId: data.calendarId.present
          ? data.calendarId.value
          : this.calendarId,
      summary: data.summary.present ? data.summary.value : this.summary,
      startTs: data.startTs.present ? data.startTs.value : this.startTs,
      endTs: data.endTs.present ? data.endTs.value : this.endTs,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      updated: data.updated.present ? data.updated.value : this.updated,
      isThreshold: data.isThreshold.present
          ? data.isThreshold.value
          : this.isThreshold,
      status: data.status.present ? data.status.value : this.status,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      adoptedTaskUid: data.adoptedTaskUid.present
          ? data.adoptedTaskUid.value
          : this.adoptedTaskUid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoogleEventRow(')
          ..write('eventId: $eventId, ')
          ..write('calendarId: $calendarId, ')
          ..write('summary: $summary, ')
          ..write('startTs: $startTs, ')
          ..write('endTs: $endTs, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('updated: $updated, ')
          ..write('isThreshold: $isThreshold, ')
          ..write('status: $status, ')
          ..write('eventType: $eventType, ')
          ..write('adoptedTaskUid: $adoptedTaskUid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    calendarId,
    summary,
    startTs,
    endTs,
    isAllDay,
    updated,
    isThreshold,
    status,
    eventType,
    adoptedTaskUid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoogleEventRow &&
          other.eventId == this.eventId &&
          other.calendarId == this.calendarId &&
          other.summary == this.summary &&
          other.startTs == this.startTs &&
          other.endTs == this.endTs &&
          other.isAllDay == this.isAllDay &&
          other.updated == this.updated &&
          other.isThreshold == this.isThreshold &&
          other.status == this.status &&
          other.eventType == this.eventType &&
          other.adoptedTaskUid == this.adoptedTaskUid);
}

class GoogleEventMapCompanion extends UpdateCompanion<GoogleEventRow> {
  final Value<String> eventId;
  final Value<String> calendarId;
  final Value<String> summary;
  final Value<int?> startTs;
  final Value<int?> endTs;
  final Value<bool> isAllDay;
  final Value<String> updated;
  final Value<bool> isThreshold;
  final Value<String> status;
  final Value<String> eventType;
  final Value<String?> adoptedTaskUid;
  final Value<int> rowid;
  const GoogleEventMapCompanion({
    this.eventId = const Value.absent(),
    this.calendarId = const Value.absent(),
    this.summary = const Value.absent(),
    this.startTs = const Value.absent(),
    this.endTs = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.updated = const Value.absent(),
    this.isThreshold = const Value.absent(),
    this.status = const Value.absent(),
    this.eventType = const Value.absent(),
    this.adoptedTaskUid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoogleEventMapCompanion.insert({
    required String eventId,
    required String calendarId,
    this.summary = const Value.absent(),
    this.startTs = const Value.absent(),
    this.endTs = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.updated = const Value.absent(),
    this.isThreshold = const Value.absent(),
    this.status = const Value.absent(),
    this.eventType = const Value.absent(),
    this.adoptedTaskUid = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       calendarId = Value(calendarId);
  static Insertable<GoogleEventRow> custom({
    Expression<String>? eventId,
    Expression<String>? calendarId,
    Expression<String>? summary,
    Expression<int>? startTs,
    Expression<int>? endTs,
    Expression<bool>? isAllDay,
    Expression<String>? updated,
    Expression<bool>? isThreshold,
    Expression<String>? status,
    Expression<String>? eventType,
    Expression<String>? adoptedTaskUid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (calendarId != null) 'calendar_id': calendarId,
      if (summary != null) 'summary': summary,
      if (startTs != null) 'start_ts': startTs,
      if (endTs != null) 'end_ts': endTs,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (updated != null) 'updated': updated,
      if (isThreshold != null) 'is_threshold': isThreshold,
      if (status != null) 'status': status,
      if (eventType != null) 'event_type': eventType,
      if (adoptedTaskUid != null) 'adopted_task_uid': adoptedTaskUid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoogleEventMapCompanion copyWith({
    Value<String>? eventId,
    Value<String>? calendarId,
    Value<String>? summary,
    Value<int?>? startTs,
    Value<int?>? endTs,
    Value<bool>? isAllDay,
    Value<String>? updated,
    Value<bool>? isThreshold,
    Value<String>? status,
    Value<String>? eventType,
    Value<String?>? adoptedTaskUid,
    Value<int>? rowid,
  }) {
    return GoogleEventMapCompanion(
      eventId: eventId ?? this.eventId,
      calendarId: calendarId ?? this.calendarId,
      summary: summary ?? this.summary,
      startTs: startTs ?? this.startTs,
      endTs: endTs ?? this.endTs,
      isAllDay: isAllDay ?? this.isAllDay,
      updated: updated ?? this.updated,
      isThreshold: isThreshold ?? this.isThreshold,
      status: status ?? this.status,
      eventType: eventType ?? this.eventType,
      adoptedTaskUid: adoptedTaskUid ?? this.adoptedTaskUid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (calendarId.present) {
      map['calendar_id'] = Variable<String>(calendarId.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (startTs.present) {
      map['start_ts'] = Variable<int>(startTs.value);
    }
    if (endTs.present) {
      map['end_ts'] = Variable<int>(endTs.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (updated.present) {
      map['updated'] = Variable<String>(updated.value);
    }
    if (isThreshold.present) {
      map['is_threshold'] = Variable<bool>(isThreshold.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (adoptedTaskUid.present) {
      map['adopted_task_uid'] = Variable<String>(adoptedTaskUid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoogleEventMapCompanion(')
          ..write('eventId: $eventId, ')
          ..write('calendarId: $calendarId, ')
          ..write('summary: $summary, ')
          ..write('startTs: $startTs, ')
          ..write('endTs: $endTs, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('updated: $updated, ')
          ..write('isThreshold: $isThreshold, ')
          ..write('status: $status, ')
          ..write('eventType: $eventType, ')
          ..write('adoptedTaskUid: $adoptedTaskUid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _calendarIdMeta = const VerificationMeta(
    'calendarId',
  );
  @override
  late final GeneratedColumn<String> calendarId = GeneratedColumn<String>(
    'calendar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncTokenMeta = const VerificationMeta(
    'syncToken',
  );
  @override
  late final GeneratedColumn<String> syncToken = GeneratedColumn<String>(
    'sync_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncTsMeta = const VerificationMeta(
    'lastSyncTs',
  );
  @override
  late final GeneratedColumn<int> lastSyncTs = GeneratedColumn<int>(
    'last_sync_ts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastStatusMeta = const VerificationMeta(
    'lastStatus',
  );
  @override
  late final GeneratedColumn<String> lastStatus = GeneratedColumn<String>(
    'last_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    calendarId,
    syncToken,
    lastSyncTs,
    lastStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('calendar_id')) {
      context.handle(
        _calendarIdMeta,
        calendarId.isAcceptableOrUnknown(data['calendar_id']!, _calendarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_calendarIdMeta);
    }
    if (data.containsKey('sync_token')) {
      context.handle(
        _syncTokenMeta,
        syncToken.isAcceptableOrUnknown(data['sync_token']!, _syncTokenMeta),
      );
    }
    if (data.containsKey('last_sync_ts')) {
      context.handle(
        _lastSyncTsMeta,
        lastSyncTs.isAcceptableOrUnknown(
          data['last_sync_ts']!,
          _lastSyncTsMeta,
        ),
      );
    }
    if (data.containsKey('last_status')) {
      context.handle(
        _lastStatusMeta,
        lastStatus.isAcceptableOrUnknown(data['last_status']!, _lastStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {calendarId};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      calendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_id'],
      )!,
      syncToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_token'],
      ),
      lastSyncTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_ts'],
      ),
      lastStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_status'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String calendarId;
  final String? syncToken;
  final int? lastSyncTs;
  final String? lastStatus;
  const SyncStateRow({
    required this.calendarId,
    this.syncToken,
    this.lastSyncTs,
    this.lastStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['calendar_id'] = Variable<String>(calendarId);
    if (!nullToAbsent || syncToken != null) {
      map['sync_token'] = Variable<String>(syncToken);
    }
    if (!nullToAbsent || lastSyncTs != null) {
      map['last_sync_ts'] = Variable<int>(lastSyncTs);
    }
    if (!nullToAbsent || lastStatus != null) {
      map['last_status'] = Variable<String>(lastStatus);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      calendarId: Value(calendarId),
      syncToken: syncToken == null && nullToAbsent
          ? const Value.absent()
          : Value(syncToken),
      lastSyncTs: lastSyncTs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncTs),
      lastStatus: lastStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStatus),
    );
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      calendarId: serializer.fromJson<String>(json['calendarId']),
      syncToken: serializer.fromJson<String?>(json['syncToken']),
      lastSyncTs: serializer.fromJson<int?>(json['lastSyncTs']),
      lastStatus: serializer.fromJson<String?>(json['lastStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'calendarId': serializer.toJson<String>(calendarId),
      'syncToken': serializer.toJson<String?>(syncToken),
      'lastSyncTs': serializer.toJson<int?>(lastSyncTs),
      'lastStatus': serializer.toJson<String?>(lastStatus),
    };
  }

  SyncStateRow copyWith({
    String? calendarId,
    Value<String?> syncToken = const Value.absent(),
    Value<int?> lastSyncTs = const Value.absent(),
    Value<String?> lastStatus = const Value.absent(),
  }) => SyncStateRow(
    calendarId: calendarId ?? this.calendarId,
    syncToken: syncToken.present ? syncToken.value : this.syncToken,
    lastSyncTs: lastSyncTs.present ? lastSyncTs.value : this.lastSyncTs,
    lastStatus: lastStatus.present ? lastStatus.value : this.lastStatus,
  );
  SyncStateRow copyWithCompanion(SyncStateCompanion data) {
    return SyncStateRow(
      calendarId: data.calendarId.present
          ? data.calendarId.value
          : this.calendarId,
      syncToken: data.syncToken.present ? data.syncToken.value : this.syncToken,
      lastSyncTs: data.lastSyncTs.present
          ? data.lastSyncTs.value
          : this.lastSyncTs,
      lastStatus: data.lastStatus.present
          ? data.lastStatus.value
          : this.lastStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('calendarId: $calendarId, ')
          ..write('syncToken: $syncToken, ')
          ..write('lastSyncTs: $lastSyncTs, ')
          ..write('lastStatus: $lastStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(calendarId, syncToken, lastSyncTs, lastStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.calendarId == this.calendarId &&
          other.syncToken == this.syncToken &&
          other.lastSyncTs == this.lastSyncTs &&
          other.lastStatus == this.lastStatus);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> calendarId;
  final Value<String?> syncToken;
  final Value<int?> lastSyncTs;
  final Value<String?> lastStatus;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.calendarId = const Value.absent(),
    this.syncToken = const Value.absent(),
    this.lastSyncTs = const Value.absent(),
    this.lastStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String calendarId,
    this.syncToken = const Value.absent(),
    this.lastSyncTs = const Value.absent(),
    this.lastStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : calendarId = Value(calendarId);
  static Insertable<SyncStateRow> custom({
    Expression<String>? calendarId,
    Expression<String>? syncToken,
    Expression<int>? lastSyncTs,
    Expression<String>? lastStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (calendarId != null) 'calendar_id': calendarId,
      if (syncToken != null) 'sync_token': syncToken,
      if (lastSyncTs != null) 'last_sync_ts': lastSyncTs,
      if (lastStatus != null) 'last_status': lastStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? calendarId,
    Value<String?>? syncToken,
    Value<int?>? lastSyncTs,
    Value<String?>? lastStatus,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      calendarId: calendarId ?? this.calendarId,
      syncToken: syncToken ?? this.syncToken,
      lastSyncTs: lastSyncTs ?? this.lastSyncTs,
      lastStatus: lastStatus ?? this.lastStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (calendarId.present) {
      map['calendar_id'] = Variable<String>(calendarId.value);
    }
    if (syncToken.present) {
      map['sync_token'] = Variable<String>(syncToken.value);
    }
    if (lastSyncTs.present) {
      map['last_sync_ts'] = Variable<int>(lastSyncTs.value);
    }
    if (lastStatus.present) {
      map['last_status'] = Variable<String>(lastStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('calendarId: $calendarId, ')
          ..write('syncToken: $syncToken, ')
          ..write('lastSyncTs: $lastSyncTs, ')
          ..write('lastStatus: $lastStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOpsTable extends PendingOps
    with TableInfo<$PendingOpsTable, PendingOpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskUidMeta = const VerificationMeta(
    'taskUid',
  );
  @override
  late final GeneratedColumn<String> taskUid = GeneratedColumn<String>(
    'task_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdTsMeta = const VerificationMeta(
    'createdTs',
  );
  @override
  late final GeneratedColumn<int> createdTs = GeneratedColumn<int>(
    'created_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskUid,
    kind,
    payload,
    createdTs,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOpRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_uid')) {
      context.handle(
        _taskUidMeta,
        taskUid.isAcceptableOrUnknown(data['task_uid']!, _taskUidMeta),
      );
    } else if (isInserting) {
      context.missing(_taskUidMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('created_ts')) {
      context.handle(
        _createdTsMeta,
        createdTs.isAcceptableOrUnknown(data['created_ts']!, _createdTsMeta),
      );
    } else if (isInserting) {
      context.missing(_createdTsMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOpRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_uid'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_ts'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PendingOpsTable createAlias(String alias) {
    return $PendingOpsTable(attachedDatabase, alias);
  }
}

class PendingOpRow extends DataClass implements Insertable<PendingOpRow> {
  final int id;
  final String taskUid;
  final String kind;
  final String payload;
  final int createdTs;
  final int attempts;
  final String? lastError;
  const PendingOpRow({
    required this.id,
    required this.taskUid,
    required this.kind,
    required this.payload,
    required this.createdTs,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_uid'] = Variable<String>(taskUid);
    map['kind'] = Variable<String>(kind);
    map['payload'] = Variable<String>(payload);
    map['created_ts'] = Variable<int>(createdTs);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PendingOpsCompanion toCompanion(bool nullToAbsent) {
    return PendingOpsCompanion(
      id: Value(id),
      taskUid: Value(taskUid),
      kind: Value(kind),
      payload: Value(payload),
      createdTs: Value(createdTs),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PendingOpRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOpRow(
      id: serializer.fromJson<int>(json['id']),
      taskUid: serializer.fromJson<String>(json['taskUid']),
      kind: serializer.fromJson<String>(json['kind']),
      payload: serializer.fromJson<String>(json['payload']),
      createdTs: serializer.fromJson<int>(json['createdTs']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskUid': serializer.toJson<String>(taskUid),
      'kind': serializer.toJson<String>(kind),
      'payload': serializer.toJson<String>(payload),
      'createdTs': serializer.toJson<int>(createdTs),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PendingOpRow copyWith({
    int? id,
    String? taskUid,
    String? kind,
    String? payload,
    int? createdTs,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => PendingOpRow(
    id: id ?? this.id,
    taskUid: taskUid ?? this.taskUid,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
    createdTs: createdTs ?? this.createdTs,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PendingOpRow copyWithCompanion(PendingOpsCompanion data) {
    return PendingOpRow(
      id: data.id.present ? data.id.value : this.id,
      taskUid: data.taskUid.present ? data.taskUid.value : this.taskUid,
      kind: data.kind.present ? data.kind.value : this.kind,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdTs: data.createdTs.present ? data.createdTs.value : this.createdTs,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOpRow(')
          ..write('id: $id, ')
          ..write('taskUid: $taskUid, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('createdTs: $createdTs, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, taskUid, kind, payload, createdTs, attempts, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOpRow &&
          other.id == this.id &&
          other.taskUid == this.taskUid &&
          other.kind == this.kind &&
          other.payload == this.payload &&
          other.createdTs == this.createdTs &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class PendingOpsCompanion extends UpdateCompanion<PendingOpRow> {
  final Value<int> id;
  final Value<String> taskUid;
  final Value<String> kind;
  final Value<String> payload;
  final Value<int> createdTs;
  final Value<int> attempts;
  final Value<String?> lastError;
  const PendingOpsCompanion({
    this.id = const Value.absent(),
    this.taskUid = const Value.absent(),
    this.kind = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdTs = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  PendingOpsCompanion.insert({
    this.id = const Value.absent(),
    required String taskUid,
    required String kind,
    this.payload = const Value.absent(),
    required int createdTs,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : taskUid = Value(taskUid),
       kind = Value(kind),
       createdTs = Value(createdTs);
  static Insertable<PendingOpRow> custom({
    Expression<int>? id,
    Expression<String>? taskUid,
    Expression<String>? kind,
    Expression<String>? payload,
    Expression<int>? createdTs,
    Expression<int>? attempts,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskUid != null) 'task_uid': taskUid,
      if (kind != null) 'kind': kind,
      if (payload != null) 'payload': payload,
      if (createdTs != null) 'created_ts': createdTs,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
    });
  }

  PendingOpsCompanion copyWith({
    Value<int>? id,
    Value<String>? taskUid,
    Value<String>? kind,
    Value<String>? payload,
    Value<int>? createdTs,
    Value<int>? attempts,
    Value<String?>? lastError,
  }) {
    return PendingOpsCompanion(
      id: id ?? this.id,
      taskUid: taskUid ?? this.taskUid,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      createdTs: createdTs ?? this.createdTs,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskUid.present) {
      map['task_uid'] = Variable<String>(taskUid.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdTs.present) {
      map['created_ts'] = Variable<int>(createdTs.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOpsCompanion(')
          ..write('id: $id, ')
          ..write('taskUid: $taskUid, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('createdTs: $createdTs, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $AreasTable areas = $AreasTable(this);
  late final $SettingsKVTable settingsKV = $SettingsKVTable(this);
  late final $GoogleEventMapTable googleEventMap = $GoogleEventMapTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $PendingOpsTable pendingOps = $PendingOpsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    areas,
    settingsKV,
    googleEventMap,
    syncState,
    pendingOps,
  ];
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String uid,
      required String title,
      Value<String?> note,
      Value<String?> areaUid,
      Value<bool?> urgent,
      Value<bool?> important,
      Value<int> sortOrder,
      Value<String> status,
      required String createdTs,
      Value<String?> completedTs,
      Value<int?> scheduledTs,
      Value<String?> calendarEventId,
      Value<String?> calendarHtmlLink,
      Value<String?> repeatDays,
      Value<int?> remindFiredForTs,
      Value<int?> remindSnoozedUntil,
      Value<String?> boardEventId,
      Value<int?> legacyDesktopId,
      required int updatedTs,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<String> title,
      Value<String?> note,
      Value<String?> areaUid,
      Value<bool?> urgent,
      Value<bool?> important,
      Value<int> sortOrder,
      Value<String> status,
      Value<String> createdTs,
      Value<String?> completedTs,
      Value<int?> scheduledTs,
      Value<String?> calendarEventId,
      Value<String?> calendarHtmlLink,
      Value<String?> repeatDays,
      Value<int?> remindFiredForTs,
      Value<int?> remindSnoozedUntil,
      Value<String?> boardEventId,
      Value<int?> legacyDesktopId,
      Value<int> updatedTs,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaUid => $composableBuilder(
    column: $table.areaUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get urgent => $composableBuilder(
    column: $table.urgent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get important => $composableBuilder(
    column: $table.important,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdTs => $composableBuilder(
    column: $table.createdTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedTs => $composableBuilder(
    column: $table.completedTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledTs => $composableBuilder(
    column: $table.scheduledTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarHtmlLink => $composableBuilder(
    column: $table.calendarHtmlLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remindFiredForTs => $composableBuilder(
    column: $table.remindFiredForTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remindSnoozedUntil => $composableBuilder(
    column: $table.remindSnoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boardEventId => $composableBuilder(
    column: $table.boardEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get legacyDesktopId => $composableBuilder(
    column: $table.legacyDesktopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedTs => $composableBuilder(
    column: $table.updatedTs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaUid => $composableBuilder(
    column: $table.areaUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get urgent => $composableBuilder(
    column: $table.urgent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get important => $composableBuilder(
    column: $table.important,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdTs => $composableBuilder(
    column: $table.createdTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedTs => $composableBuilder(
    column: $table.completedTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledTs => $composableBuilder(
    column: $table.scheduledTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarHtmlLink => $composableBuilder(
    column: $table.calendarHtmlLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remindFiredForTs => $composableBuilder(
    column: $table.remindFiredForTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remindSnoozedUntil => $composableBuilder(
    column: $table.remindSnoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boardEventId => $composableBuilder(
    column: $table.boardEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get legacyDesktopId => $composableBuilder(
    column: $table.legacyDesktopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedTs => $composableBuilder(
    column: $table.updatedTs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get areaUid =>
      $composableBuilder(column: $table.areaUid, builder: (column) => column);

  GeneratedColumn<bool> get urgent =>
      $composableBuilder(column: $table.urgent, builder: (column) => column);

  GeneratedColumn<bool> get important =>
      $composableBuilder(column: $table.important, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdTs =>
      $composableBuilder(column: $table.createdTs, builder: (column) => column);

  GeneratedColumn<String> get completedTs => $composableBuilder(
    column: $table.completedTs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledTs => $composableBuilder(
    column: $table.scheduledTs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarHtmlLink => $composableBuilder(
    column: $table.calendarHtmlLink,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remindFiredForTs => $composableBuilder(
    column: $table.remindFiredForTs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remindSnoozedUntil => $composableBuilder(
    column: $table.remindSnoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get boardEventId => $composableBuilder(
    column: $table.boardEventId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get legacyDesktopId => $composableBuilder(
    column: $table.legacyDesktopId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedTs =>
      $composableBuilder(column: $table.updatedTs, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> areaUid = const Value.absent(),
                Value<bool?> urgent = const Value.absent(),
                Value<bool?> important = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdTs = const Value.absent(),
                Value<String?> completedTs = const Value.absent(),
                Value<int?> scheduledTs = const Value.absent(),
                Value<String?> calendarEventId = const Value.absent(),
                Value<String?> calendarHtmlLink = const Value.absent(),
                Value<String?> repeatDays = const Value.absent(),
                Value<int?> remindFiredForTs = const Value.absent(),
                Value<int?> remindSnoozedUntil = const Value.absent(),
                Value<String?> boardEventId = const Value.absent(),
                Value<int?> legacyDesktopId = const Value.absent(),
                Value<int> updatedTs = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                uid: uid,
                title: title,
                note: note,
                areaUid: areaUid,
                urgent: urgent,
                important: important,
                sortOrder: sortOrder,
                status: status,
                createdTs: createdTs,
                completedTs: completedTs,
                scheduledTs: scheduledTs,
                calendarEventId: calendarEventId,
                calendarHtmlLink: calendarHtmlLink,
                repeatDays: repeatDays,
                remindFiredForTs: remindFiredForTs,
                remindSnoozedUntil: remindSnoozedUntil,
                boardEventId: boardEventId,
                legacyDesktopId: legacyDesktopId,
                updatedTs: updatedTs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uid,
                required String title,
                Value<String?> note = const Value.absent(),
                Value<String?> areaUid = const Value.absent(),
                Value<bool?> urgent = const Value.absent(),
                Value<bool?> important = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> status = const Value.absent(),
                required String createdTs,
                Value<String?> completedTs = const Value.absent(),
                Value<int?> scheduledTs = const Value.absent(),
                Value<String?> calendarEventId = const Value.absent(),
                Value<String?> calendarHtmlLink = const Value.absent(),
                Value<String?> repeatDays = const Value.absent(),
                Value<int?> remindFiredForTs = const Value.absent(),
                Value<int?> remindSnoozedUntil = const Value.absent(),
                Value<String?> boardEventId = const Value.absent(),
                Value<int?> legacyDesktopId = const Value.absent(),
                required int updatedTs,
              }) => TasksCompanion.insert(
                id: id,
                uid: uid,
                title: title,
                note: note,
                areaUid: areaUid,
                urgent: urgent,
                important: important,
                sortOrder: sortOrder,
                status: status,
                createdTs: createdTs,
                completedTs: completedTs,
                scheduledTs: scheduledTs,
                calendarEventId: calendarEventId,
                calendarHtmlLink: calendarHtmlLink,
                repeatDays: repeatDays,
                remindFiredForTs: remindFiredForTs,
                remindSnoozedUntil: remindSnoozedUntil,
                boardEventId: boardEventId,
                legacyDesktopId: legacyDesktopId,
                updatedTs: updatedTs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$AreasTableCreateCompanionBuilder =
    AreasCompanion Function({
      required String uid,
      required String name,
      required int sortOrder,
      required int updatedTs,
      Value<int> rowid,
    });
typedef $$AreasTableUpdateCompanionBuilder =
    AreasCompanion Function({
      Value<String> uid,
      Value<String> name,
      Value<int> sortOrder,
      Value<int> updatedTs,
      Value<int> rowid,
    });

class $$AreasTableFilterComposer extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedTs => $composableBuilder(
    column: $table.updatedTs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AreasTableOrderingComposer
    extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedTs => $composableBuilder(
    column: $table.updatedTs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AreasTableAnnotationComposer
    extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get updatedTs =>
      $composableBuilder(column: $table.updatedTs, builder: (column) => column);
}

class $$AreasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AreasTable,
          AreaRow,
          $$AreasTableFilterComposer,
          $$AreasTableOrderingComposer,
          $$AreasTableAnnotationComposer,
          $$AreasTableCreateCompanionBuilder,
          $$AreasTableUpdateCompanionBuilder,
          (AreaRow, BaseReferences<_$AppDatabase, $AreasTable, AreaRow>),
          AreaRow,
          PrefetchHooks Function()
        > {
  $$AreasTableTableManager(_$AppDatabase db, $AreasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> updatedTs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AreasCompanion(
                uid: uid,
                name: name,
                sortOrder: sortOrder,
                updatedTs: updatedTs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uid,
                required String name,
                required int sortOrder,
                required int updatedTs,
                Value<int> rowid = const Value.absent(),
              }) => AreasCompanion.insert(
                uid: uid,
                name: name,
                sortOrder: sortOrder,
                updatedTs: updatedTs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AreasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AreasTable,
      AreaRow,
      $$AreasTableFilterComposer,
      $$AreasTableOrderingComposer,
      $$AreasTableAnnotationComposer,
      $$AreasTableCreateCompanionBuilder,
      $$AreasTableUpdateCompanionBuilder,
      (AreaRow, BaseReferences<_$AppDatabase, $AreasTable, AreaRow>),
      AreaRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsKVTableCreateCompanionBuilder =
    SettingsKVCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsKVTableUpdateCompanionBuilder =
    SettingsKVCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsKVTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsKVTable> {
  $$SettingsKVTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsKVTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsKVTable> {
  $$SettingsKVTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsKVTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsKVTable> {
  $$SettingsKVTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsKVTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsKVTable,
          SettingsKVData,
          $$SettingsKVTableFilterComposer,
          $$SettingsKVTableOrderingComposer,
          $$SettingsKVTableAnnotationComposer,
          $$SettingsKVTableCreateCompanionBuilder,
          $$SettingsKVTableUpdateCompanionBuilder,
          (
            SettingsKVData,
            BaseReferences<_$AppDatabase, $SettingsKVTable, SettingsKVData>,
          ),
          SettingsKVData,
          PrefetchHooks Function()
        > {
  $$SettingsKVTableTableManager(_$AppDatabase db, $SettingsKVTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsKVTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsKVTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsKVTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsKVCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsKVCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsKVTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsKVTable,
      SettingsKVData,
      $$SettingsKVTableFilterComposer,
      $$SettingsKVTableOrderingComposer,
      $$SettingsKVTableAnnotationComposer,
      $$SettingsKVTableCreateCompanionBuilder,
      $$SettingsKVTableUpdateCompanionBuilder,
      (
        SettingsKVData,
        BaseReferences<_$AppDatabase, $SettingsKVTable, SettingsKVData>,
      ),
      SettingsKVData,
      PrefetchHooks Function()
    >;
typedef $$GoogleEventMapTableCreateCompanionBuilder =
    GoogleEventMapCompanion Function({
      required String eventId,
      required String calendarId,
      Value<String> summary,
      Value<int?> startTs,
      Value<int?> endTs,
      Value<bool> isAllDay,
      Value<String> updated,
      Value<bool> isThreshold,
      Value<String> status,
      Value<String> eventType,
      Value<String?> adoptedTaskUid,
      Value<int> rowid,
    });
typedef $$GoogleEventMapTableUpdateCompanionBuilder =
    GoogleEventMapCompanion Function({
      Value<String> eventId,
      Value<String> calendarId,
      Value<String> summary,
      Value<int?> startTs,
      Value<int?> endTs,
      Value<bool> isAllDay,
      Value<String> updated,
      Value<bool> isThreshold,
      Value<String> status,
      Value<String> eventType,
      Value<String?> adoptedTaskUid,
      Value<int> rowid,
    });

class $$GoogleEventMapTableFilterComposer
    extends Composer<_$AppDatabase, $GoogleEventMapTable> {
  $$GoogleEventMapTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTs => $composableBuilder(
    column: $table.startTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTs => $composableBuilder(
    column: $table.endTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isThreshold => $composableBuilder(
    column: $table.isThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adoptedTaskUid => $composableBuilder(
    column: $table.adoptedTaskUid,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoogleEventMapTableOrderingComposer
    extends Composer<_$AppDatabase, $GoogleEventMapTable> {
  $$GoogleEventMapTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTs => $composableBuilder(
    column: $table.startTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTs => $composableBuilder(
    column: $table.endTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isThreshold => $composableBuilder(
    column: $table.isThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adoptedTaskUid => $composableBuilder(
    column: $table.adoptedTaskUid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoogleEventMapTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoogleEventMapTable> {
  $$GoogleEventMapTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<int> get startTs =>
      $composableBuilder(column: $table.startTs, builder: (column) => column);

  GeneratedColumn<int> get endTs =>
      $composableBuilder(column: $table.endTs, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<String> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  GeneratedColumn<bool> get isThreshold => $composableBuilder(
    column: $table.isThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get adoptedTaskUid => $composableBuilder(
    column: $table.adoptedTaskUid,
    builder: (column) => column,
  );
}

class $$GoogleEventMapTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoogleEventMapTable,
          GoogleEventRow,
          $$GoogleEventMapTableFilterComposer,
          $$GoogleEventMapTableOrderingComposer,
          $$GoogleEventMapTableAnnotationComposer,
          $$GoogleEventMapTableCreateCompanionBuilder,
          $$GoogleEventMapTableUpdateCompanionBuilder,
          (
            GoogleEventRow,
            BaseReferences<_$AppDatabase, $GoogleEventMapTable, GoogleEventRow>,
          ),
          GoogleEventRow,
          PrefetchHooks Function()
        > {
  $$GoogleEventMapTableTableManager(
    _$AppDatabase db,
    $GoogleEventMapTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoogleEventMapTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoogleEventMapTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoogleEventMapTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> calendarId = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<int?> startTs = const Value.absent(),
                Value<int?> endTs = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<String> updated = const Value.absent(),
                Value<bool> isThreshold = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> adoptedTaskUid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoogleEventMapCompanion(
                eventId: eventId,
                calendarId: calendarId,
                summary: summary,
                startTs: startTs,
                endTs: endTs,
                isAllDay: isAllDay,
                updated: updated,
                isThreshold: isThreshold,
                status: status,
                eventType: eventType,
                adoptedTaskUid: adoptedTaskUid,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String calendarId,
                Value<String> summary = const Value.absent(),
                Value<int?> startTs = const Value.absent(),
                Value<int?> endTs = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<String> updated = const Value.absent(),
                Value<bool> isThreshold = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> adoptedTaskUid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoogleEventMapCompanion.insert(
                eventId: eventId,
                calendarId: calendarId,
                summary: summary,
                startTs: startTs,
                endTs: endTs,
                isAllDay: isAllDay,
                updated: updated,
                isThreshold: isThreshold,
                status: status,
                eventType: eventType,
                adoptedTaskUid: adoptedTaskUid,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoogleEventMapTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoogleEventMapTable,
      GoogleEventRow,
      $$GoogleEventMapTableFilterComposer,
      $$GoogleEventMapTableOrderingComposer,
      $$GoogleEventMapTableAnnotationComposer,
      $$GoogleEventMapTableCreateCompanionBuilder,
      $$GoogleEventMapTableUpdateCompanionBuilder,
      (
        GoogleEventRow,
        BaseReferences<_$AppDatabase, $GoogleEventMapTable, GoogleEventRow>,
      ),
      GoogleEventRow,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String calendarId,
      Value<String?> syncToken,
      Value<int?> lastSyncTs,
      Value<String?> lastStatus,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> calendarId,
      Value<String?> syncToken,
      Value<int?> lastSyncTs,
      Value<String?> lastStatus,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncToken => $composableBuilder(
    column: $table.syncToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncTs => $composableBuilder(
    column: $table.lastSyncTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastStatus => $composableBuilder(
    column: $table.lastStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncToken => $composableBuilder(
    column: $table.syncToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncTs => $composableBuilder(
    column: $table.lastSyncTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastStatus => $composableBuilder(
    column: $table.lastStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncToken =>
      $composableBuilder(column: $table.syncToken, builder: (column) => column);

  GeneratedColumn<int> get lastSyncTs => $composableBuilder(
    column: $table.lastSyncTs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastStatus => $composableBuilder(
    column: $table.lastStatus,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateRow,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> calendarId = const Value.absent(),
                Value<String?> syncToken = const Value.absent(),
                Value<int?> lastSyncTs = const Value.absent(),
                Value<String?> lastStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                calendarId: calendarId,
                syncToken: syncToken,
                lastSyncTs: lastSyncTs,
                lastStatus: lastStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String calendarId,
                Value<String?> syncToken = const Value.absent(),
                Value<int?> lastSyncTs = const Value.absent(),
                Value<String?> lastStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                calendarId: calendarId,
                syncToken: syncToken,
                lastSyncTs: lastSyncTs,
                lastStatus: lastStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateRow,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;
typedef $$PendingOpsTableCreateCompanionBuilder =
    PendingOpsCompanion Function({
      Value<int> id,
      required String taskUid,
      required String kind,
      Value<String> payload,
      required int createdTs,
      Value<int> attempts,
      Value<String?> lastError,
    });
typedef $$PendingOpsTableUpdateCompanionBuilder =
    PendingOpsCompanion Function({
      Value<int> id,
      Value<String> taskUid,
      Value<String> kind,
      Value<String> payload,
      Value<int> createdTs,
      Value<int> attempts,
      Value<String?> lastError,
    });

class $$PendingOpsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskUid => $composableBuilder(
    column: $table.taskUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdTs => $composableBuilder(
    column: $table.createdTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskUid => $composableBuilder(
    column: $table.taskUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdTs => $composableBuilder(
    column: $table.createdTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskUid =>
      $composableBuilder(column: $table.taskUid, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdTs =>
      $composableBuilder(column: $table.createdTs, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PendingOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingOpsTable,
          PendingOpRow,
          $$PendingOpsTableFilterComposer,
          $$PendingOpsTableOrderingComposer,
          $$PendingOpsTableAnnotationComposer,
          $$PendingOpsTableCreateCompanionBuilder,
          $$PendingOpsTableUpdateCompanionBuilder,
          (
            PendingOpRow,
            BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOpRow>,
          ),
          PendingOpRow,
          PrefetchHooks Function()
        > {
  $$PendingOpsTableTableManager(_$AppDatabase db, $PendingOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> taskUid = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> createdTs = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingOpsCompanion(
                id: id,
                taskUid: taskUid,
                kind: kind,
                payload: payload,
                createdTs: createdTs,
                attempts: attempts,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String taskUid,
                required String kind,
                Value<String> payload = const Value.absent(),
                required int createdTs,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingOpsCompanion.insert(
                id: id,
                taskUid: taskUid,
                kind: kind,
                payload: payload,
                createdTs: createdTs,
                attempts: attempts,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingOpsTable,
      PendingOpRow,
      $$PendingOpsTableFilterComposer,
      $$PendingOpsTableOrderingComposer,
      $$PendingOpsTableAnnotationComposer,
      $$PendingOpsTableCreateCompanionBuilder,
      $$PendingOpsTableUpdateCompanionBuilder,
      (
        PendingOpRow,
        BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOpRow>,
      ),
      PendingOpRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$AreasTableTableManager get areas =>
      $$AreasTableTableManager(_db, _db.areas);
  $$SettingsKVTableTableManager get settingsKV =>
      $$SettingsKVTableTableManager(_db, _db.settingsKV);
  $$GoogleEventMapTableTableManager get googleEventMap =>
      $$GoogleEventMapTableTableManager(_db, _db.googleEventMap);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$PendingOpsTableTableManager get pendingOps =>
      $$PendingOpsTableTableManager(_db, _db.pendingOps);
}
