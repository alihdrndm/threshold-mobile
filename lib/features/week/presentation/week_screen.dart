import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/caps_label.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../calendar_sync/presentation/sync_providers.dart';
import '../../tasks/presentation/providers.dart';

/// The coming week, day by day: your scheduled tasks (accent-edged) and —
/// unlike the desktop's anonymous busy stripes — foreign Google events
/// with their titles. Adoption arrives with M3.
final weekEventsProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.googleEventMap)
        ..orderBy([(g) => OrderingTerm.asc(g.startTs)]))
      .watch();
});

class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final status = ref.watch(calendarStatusProvider).value;
    final events = ref.watch(weekEventsProvider).value ?? const [];
    final tasks = ref.watch(tasksProvider).value ?? const [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (status != null && !status.connected) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'Connect Google Calendar in Settings to see your week.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: c.inkMuted),
          ),
        ),
      );
    }

    final days = [for (var i = 0; i < 7; i++) today.add(Duration(days: i))];
    var anything = false;

    return RefreshIndicator(
      color: c.accent,
      onRefresh: () =>
          ref.read(calendarStatusProvider.notifier).syncNow(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          for (final day in days) ...[
            Builder(builder: (context) {
              final dayStart = day.millisecondsSinceEpoch ~/ 1000;
              final dayEnd = dayStart + 86400;
              final own = [
                for (final t in tasks)
                  if (t.isOpen &&
                      t.scheduledTs != null &&
                      t.scheduledTs! >= dayStart &&
                      t.scheduledTs! < dayEnd)
                    t,
              ]..sort((a, b) => a.scheduledTs!.compareTo(b.scheduledTs!));
              // Events already represented by a local task would render
              // twice; everything else shows — including the DESKTOP's own
              // Threshold events, which have no local task here until the
              // board sync lands (M4). Those wear the accent edge: they are
              // the user's tasks, wherever they were born.
              final ownEventIds = {
                for (final t in tasks)
                  if (t.calendarEventId != null) t.calendarEventId,
              };
              final remote = [
                for (final e in events)
                  if (!ownEventIds.contains(e.eventId) &&
                      e.startTs != null &&
                      e.startTs! >= dayStart &&
                      e.startTs! < dayEnd &&
                      e.eventType != 'birthday' &&
                      e.eventType != 'workingLocation')
                    e,
              ];
              if (own.isNotEmpty || remote.isNotEmpty) anything = true;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        CapsLabel(
                          day == today
                              ? 'Today'
                              : DateFormat.E().format(day),
                          color: day == today ? c.ink : null,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Opacity(
                          opacity: 0.6,
                          child: CapsLabel('${day.day}'),
                        ),
                      ],
                    ),
                  ),
                  if (own.isEmpty && remote.isEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text('—',
                          style: AppTypography.caption
                              .copyWith(color: c.inkMuted)),
                    )
                  else ...[
                    for (final t in own)
                      _Entry(
                        time: _clock(t.scheduledTs!),
                        title: t.title,
                        own: true,
                        repeating: t.repeating,
                      ),
                    for (final e in remote)
                      _Entry(
                        time: e.isAllDay ? 'All day' : _clock(e.startTs!),
                        title: e.summary.isEmpty ? '(untitled)' : e.summary,
                        own: e.isThreshold,
                      ),
                  ],
                ],
              );
            }),
          ],
          if (!anything)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              child: Center(
                child: Text('Nothing booked in the coming week.',
                    style: AppTypography.body
                        .copyWith(color: c.inkMuted)),
              ),
            ),
          if (status != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status.lastStatus != null)
                    CapsLabel(status.lastStatus!),
                  const SizedBox(width: AppSpacing.md),
                  PressableScale(
                    onPressed: () => ref
                        .read(calendarStatusProvider.notifier)
                        .syncNow(),
                    child: const CapsLabel('Sync now'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _clock(int ts) => DateFormat.jm()
      .format(DateTime.fromMillisecondsSinceEpoch(ts * 1000));
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.time,
    required this.title,
    required this.own,
    this.repeating = false,
  });

  final String time;
  final String title;
  final bool own;
  final bool repeating;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: own ? c.zone(Zone.schedule) : c.fillSubtle,
        borderRadius: BorderRadius.circular(AppRadii.item),
        border: Border(
          left: BorderSide(
              color: own ? c.accent : c.borderSubtle, width: own ? 2 : 1),
          top: BorderSide(color: c.borderSubtle),
          right: BorderSide(color: c.borderSubtle),
          bottom: BorderSide(color: c.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(time,
                style: AppTypography.caption.copyWith(
                  color: c.inkMuted,
                  fontFeatures: AppTypography.tabular,
                )),
          ),
          Expanded(
            child: Text(
              repeating ? '$title ↻' : title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(color: c.ink),
            ),
          ),
        ],
      ),
    );
  }
}
