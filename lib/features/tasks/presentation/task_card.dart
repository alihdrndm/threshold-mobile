import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/caps_label.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../domain/quadrant.dart';
import '../domain/task.dart' as domain;
import 'providers.dart';
import 'task_sheet.dart';

Zone zoneFor(Quadrant q) => switch (q) {
      Quadrant.inbox => Zone.inbox,
      Quadrant.doFirst => Zone.doFirst,
      Quadrant.schedule => Zone.schedule,
      Quadrant.delegate => Zone.delegate,
      Quadrant.eliminate => Zone.eliminate,
    };

/// The card label for a slot: "no date yet", "Today 9:30 AM", "Tomorrow…",
/// a weekday within the week, a date beyond — ` ↻` when repeating, "where
/// it is the only sign the rule exists."
String formatSlot(int? scheduledTs, DateTime now, {bool repeating = false}) {
  final mark = repeating ? ' ↻' : '';
  if (scheduledTs == null) return 'no date yet$mark';
  final when = DateTime.fromMillisecondsSinceEpoch(scheduledTs * 1000);
  final time = DateFormat.jm().format(when);
  final days = DateTime(when.year, when.month, when.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  if (days == 0) return 'Today $time$mark';
  if (days == 1) return 'Tomorrow $time$mark';
  if (days > 1 && days < 7) return '${DateFormat.E().format(when)} $time$mark';
  return '${DateFormat.MMMd().format(when)} $time$mark';
}

/// One task on the board. Ordinal, round checkbox, wrapping title (the drag
/// handle via long-press), then the control cluster — every control always
/// visible: "a control you cannot see is a control most people never find."
class TaskCard extends ConsumerWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.ordinal,
    this.showPlace = false,
  });

  final domain.Task task;
  final int? ordinal;

  /// Search results have left their position behind "and must carry the
  /// answer with it."
  final bool showPlace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final zone = zoneFor(task.quadrant);
    final repo = ref.read(taskRepositoryProvider);
    final notice = ref.read(noticeProvider.notifier);
    final areas = ref.watch(areasProvider).value ?? const [];
    final areaName = areas
        .where((a) => a.uid == task.areaUid)
        .map((a) => a.name)
        .firstOrNull;
    final done = task.status == domain.TaskStatus.done;

    Future<void> toggleDone() async {
      if (done) {
        await repo.setStatus(task.uid, domain.TaskStatus.open);
        return;
      }
      final advancedTo = await repo.complete(task.uid);
      if (advancedTo != null) {
        final old = task.scheduledTs;
        notice.say(
          'Done — back ${formatSlot(advancedTo, DateTime.now())}',
          actionLabel: 'Undo',
          action: () => repo.setSchedule(task.uid, old),
        );
      }
    }

    Future<void> delete() async {
      final previous = task.status;
      await repo.setStatus(task.uid, domain.TaskStatus.deleted);
      notice.say(
        'Deleted \u{201C}${task.title}\u{201D}',
        actionLabel: 'Undo',
        action: () => repo.setStatus(task.uid, previous),
      );
    }

    final card = Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: done ? Colors.transparent : c.cardOn(zone),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: c.borderOn(zone)),
        boxShadow: !done && c.brightness == Brightness.light
            ? const [
                BoxShadow(
                    color: Color(0x0D000000),
                    offset: Offset(0, 1),
                    blurRadius: 2),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ordinal != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: SizedBox(
                width: 16,
                child: Text(
                  '$ordinal',
                  textAlign: TextAlign.right,
                  style: AppTypography.caption.copyWith(
                    color: c.zoneInkMuted,
                    fontFeatures: AppTypography.tabular,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: PressableScale(
              onPressed: toggleDone,
              semanticLabel: done ? 'Mark as not done' : 'Mark as done',
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? c.accent.withValues(alpha: 0.2) : null,
                  border: Border.all(
                    color: done
                        ? c.accent
                        : c.zoneInkMuted.withValues(alpha: 0.7),
                  ),
                ),
                child: done
                    ? Icon(Icons.check, size: 12, color: c.accent)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showTaskSheet(context, task.uid),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      task.title,
                      style: AppTypography.taskTitle.copyWith(
                        color: done ? c.zoneInkMuted : c.ink,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: c.zoneInkMuted,
                      ),
                    ),
                  ),
                  if (showPlace ||
                      areaName != null ||
                      (task.inSchedule && !done)) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: 2,
                      children: [
                        if (task.inSchedule && !done)
                          CapsLabel(
                            formatSlot(task.scheduledTs, DateTime.now(),
                                repeating: task.repeating),
                            onZone: true,
                          ),
                        if (areaName != null)
                          CapsLabel(areaName, onZone: true),
                        if (showPlace)
                          CapsLabel(task.quadrant.label, onZone: true),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!done) ...[
            const SizedBox(width: AppSpacing.sm),
            PressableScale(
              onPressed: delete,
              semanticLabel: 'Delete \u{201C}${task.title}\u{201D}',
              child: SizedBox(
                width: 28,
                height: 28,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: c.zoneInkMuted.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (done) return card;
    // The title is the drag handle; a long-press lifts the card. "Dragging
    // leaves a slot rather than a ghost."
    return LongPressDraggable<String>(
      data: task.uid,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 10),
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: c.accent.withValues(alpha: 0.55)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xA6000000),
                  offset: Offset(0, 12),
                  blurRadius: 28,
                  spreadRadius: -8),
            ],
          ),
          child: Text(task.title,
              style: AppTypography.taskTitle.copyWith(color: c.ink)),
        ),
      ),
      childWhenDragging: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: c.accent.withValues(alpha: 0.4)),
        ),
      ),
      child: card,
    );
  }
}
