import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/caps_label.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../domain/quadrant.dart';
import '../domain/repeat.dart';
import '../domain/task.dart' as domain;
import 'providers.dart';

/// The task, opened: note, area, quadrant, and — for Schedule tasks — the
/// slot and the repeat mask. A bottom sheet standing in for the desktop's
/// popovers; every change commits as it is made, no Save button.
Future<void> showTaskSheet(BuildContext context, String uid) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // A gesture-born surface arrives on the drawer curve and leaves
    // faster than it came — the exit is the user's decision, already made.
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 280),
      reverseDuration: Duration(milliseconds: 200),
      curve: AppCurves.drawer,
      reverseCurve: AppCurves.drawer,
    ),
    builder: (_) => _TaskSheet(uid: uid),
  );
}

class _TaskSheet extends ConsumerWidget {
  const _TaskSheet({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final task = (ref.watch(tasksProvider).value ?? const [])
        .where((t) => t.uid == uid)
        .firstOrNull;
    if (task == null) return const SizedBox.shrink();
    final repo = ref.read(taskRepositoryProvider);
    final areas = ref.watch(areasProvider).value ?? const [];

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadii.zone)),
        border: Border.all(color: c.borderSubtle),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // The grab handle: the sheet admits it can be dragged.
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: c.inkMuted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
              ),
            ),
            Text(task.title,
                style: AppTypography.headline.copyWith(color: c.ink)),
            const SizedBox(height: AppSpacing.lg),

            const CapsLabel('Where it belongs'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final q in placeOrder)
                  _Pill(
                    label: q.label,
                    selected: task.quadrant == q,
                    onPressed: () => repo.moveToQuadrant(uid, q),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            const CapsLabel('Area'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final a in areas)
                  _Pill(
                    label: a.name,
                    selected: task.areaUid == a.uid,
                    onPressed: () => repo.setArea(
                        uid, task.areaUid == a.uid ? null : a.uid),
                  ),
                _Pill(
                  label: 'No area',
                  selected: task.areaUid == null,
                  onPressed: () => repo.setArea(uid, null),
                ),
              ],
            ),

            if (task.inSchedule) ...[
              const SizedBox(height: AppSpacing.xl),
              const CapsLabel('Slot'),
              const SizedBox(height: AppSpacing.sm),
              _SlotRow(task: task),
              const SizedBox(height: AppSpacing.xl),
              const CapsLabel('Repeats on'),
              const SizedBox(height: AppSpacing.sm),
              _RepeatPanel(task: task),
              const SizedBox(height: AppSpacing.xs),
              Text(
                task.repeating
                    ? 'Saved · ${formatRepeat(dayMask(task.repeatDays!))}'
                    : 'Done brings it back on these days',
                style:
                    AppTypography.caption.copyWith(color: c.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SlotRow extends ConsumerWidget {
  const _SlotRow({required this.task});

  final domain.Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final repo = ref.read(taskRepositoryProvider);
    final label = task.scheduledTs == null
        ? 'no date yet'
        : DateTime.fromMillisecondsSinceEpoch(task.scheduledTs! * 1000)
            .toString()
            .substring(0, 16);
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: AppTypography.body.copyWith(color: c.ink)),
        ),
        _Pill(
          label: 'Pick a time…',
          selected: false,
          onPressed: () async {
            final now = DateTime.now();
            final anchor = task.scheduledTs != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    task.scheduledTs! * 1000)
                : now;
            final date = await showDatePicker(
              context: context,
              initialDate: anchor,
              firstDate: now.subtract(const Duration(days: 1)),
              lastDate: now.add(const Duration(days: 365)),
            );
            if (date == null || !context.mounted) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(anchor),
            );
            if (time == null) return;
            final picked = DateTime(
                date.year, date.month, date.day, time.hour, time.minute);
            await repo.setSchedule(
                task.uid, picked.millisecondsSinceEpoch ~/ 1000);
          },
        ),
      ],
    );
  }
}

class _RepeatPanel extends ConsumerWidget {
  const _RepeatPanel({required this.task});

  final domain.Task task;

  static const _names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(taskRepositoryProvider);
    final mask = task.repeatDays != null
        ? dayMask(task.repeatDays!)
        : List<bool>.filled(7, false);

    Future<void> commit(List<bool> next) {
      final days = [
        for (var i = 0; i < 7; i++)
          if (next[i]) '${i + 1}',
      ].join(',');
      return repo.setRepeat(task.uid, days.isEmpty ? null : days);
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < 7; i++)
          _Pill(
            label: _names[i],
            selected: mask[i],
            onPressed: () {
              final next = [...mask];
              next[i] = !next[i];
              commit(next);
            },
          ),
        _Pill(
          label: 'Every day',
          selected: mask.every((d) => d),
          onPressed: () => commit(List.filled(7, true)),
        ),
        _Pill(
          label: 'Off',
          selected: !mask.contains(true),
          onPressed: () => repo.setRepeat(task.uid, null),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PressableScale(
      onPressed: onPressed,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.full),
          color: selected ? c.accent.withValues(alpha: 0.12) : c.fillSubtle,
          border: Border.all(
              color: selected ? c.accent : c.borderSubtle),
        ),
        child: Text(label,
            style: AppTypography.body.copyWith(color: c.ink)),
      ),
    );
  }
}
