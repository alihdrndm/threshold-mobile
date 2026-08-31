import 'package:meta/meta.dart';

import 'quadrant.dart';

/// The task, pure Dart. Mirrors the desktop row (through migration v7) plus
/// the mobile sync fields from HANDOFF §2.1. "A short list, not a project
/// manager. There are no due dates, no subtasks and no tags on purpose."
@immutable
class Task {
  const Task({
    required this.uid,
    required this.title,
    this.note,
    this.areaUid,
    this.urgent,
    this.important,
    required this.sortOrder,
    this.status = TaskStatus.open,
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

  final String uid;
  final String title;
  final String? note;
  final String? areaUid;
  final bool? urgent;
  final bool? important;
  final int sortOrder;
  final TaskStatus status;
  final String createdTs; // RFC3339
  final String? completedTs; // RFC3339
  final int? scheduledTs; // unix seconds — the slot, never a deadline
  final String? calendarEventId;
  final String? calendarHtmlLink;
  final String? repeatDays; // "1,3,5"; null = off
  final int? remindFiredForTs;
  final int? remindSnoozedUntil;
  final String? boardEventId;
  final int? legacyDesktopId;
  final int updatedTs; // unix seconds, LWW clock

  Quadrant get quadrant => quadrantOf(urgent, important);
  bool get isOpen => status == TaskStatus.open;
  bool get inSchedule => quadrant == Quadrant.schedule;
  bool get repeating => repeatDays != null;

  Task copyWith({
    String? title,
    Object? note = _sentinel,
    Object? areaUid = _sentinel,
    Object? urgent = _sentinel,
    Object? important = _sentinel,
    int? sortOrder,
    TaskStatus? status,
    Object? completedTs = _sentinel,
    Object? scheduledTs = _sentinel,
    Object? calendarEventId = _sentinel,
    Object? repeatDays = _sentinel,
    Object? remindFiredForTs = _sentinel,
    Object? remindSnoozedUntil = _sentinel,
    int? updatedTs,
  }) {
    return Task(
      uid: uid,
      title: title ?? this.title,
      note: note == _sentinel ? this.note : note as String?,
      areaUid: areaUid == _sentinel ? this.areaUid : areaUid as String?,
      urgent: urgent == _sentinel ? this.urgent : urgent as bool?,
      important: important == _sentinel ? this.important : important as bool?,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      createdTs: createdTs,
      completedTs:
          completedTs == _sentinel ? this.completedTs : completedTs as String?,
      scheduledTs:
          scheduledTs == _sentinel ? this.scheduledTs : scheduledTs as int?,
      calendarEventId: calendarEventId == _sentinel
          ? this.calendarEventId
          : calendarEventId as String?,
      calendarHtmlLink: calendarHtmlLink,
      repeatDays:
          repeatDays == _sentinel ? this.repeatDays : repeatDays as String?,
      remindFiredForTs: remindFiredForTs == _sentinel
          ? this.remindFiredForTs
          : remindFiredForTs as int?,
      remindSnoozedUntil: remindSnoozedUntil == _sentinel
          ? this.remindSnoozedUntil
          : remindSnoozedUntil as int?,
      boardEventId: boardEventId,
      legacyDesktopId: legacyDesktopId,
      updatedTs: updatedTs ?? this.updatedTs,
    );
  }

  static const _sentinel = Object();
}

enum TaskStatus { open, done, archived, deleted }

@immutable
class Area {
  const Area({
    required this.uid,
    required this.name,
    required this.sortOrder,
    required this.updatedTs,
  });

  final String uid;
  final String name;
  final int sortOrder;
  final int updatedTs;
}
