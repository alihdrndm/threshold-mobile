import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/arrive_in.dart';
import '../../../core/widgets/caps_label.dart';
import '../../ritual/data/ritual_repository.dart';
import 'overview_providers.dart';

/// What the record says. Counts, never a score: no targets, no streak
/// pressure, and — the rule this product has held since the desktop — no
/// graphs, ever.
class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final stats = ref.watch(overviewStatsProvider).value;

    if (stats == null) return const SizedBox.shrink();

    if (stats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'Nothing recorded yet. Every unlock from here is counted — '
            'the ones with a reason and the ones without.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: c.inkMuted),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: c.accent,
      onRefresh: () async => ref.invalidate(overviewStatsProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ArriveIn(index: 0, child: _Headline(stats: stats)),
          const SizedBox(height: AppSpacing.zoneGap),
          ArriveIn(
            index: 1,
            child: _Tiles(stats: stats),
          ),
          const SizedBox(height: AppSpacing.xl),
          ArriveIn(
            index: 2,
            child: Text(
              'A pickup for nothing is not a failure — it is the thing '
              'worth being able to see. Errands and browsing are counted '
              'beside it so the number keeps its meaning.',
              style: AppTypography.caption.copyWith(color: c.inkMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

/// The number this whole loop exists to make visible.
class _Headline extends StatelessWidget {
  const _Headline({required this.stats});

  final OverviewStats stats;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: c.zone(Zone.inbox),
        borderRadius: BorderRadius.circular(AppRadii.zone),
        border: Border.all(color: c.borderOn(Zone.inbox)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CapsLabel('Picked up for nothing'),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${stats.pickupsToday}',
                style: AppTypography.headline.copyWith(
                  color: c.ink,
                  fontSize: 44,
                  fontWeight: FontWeight.w300,
                  fontFeatures: AppTypography.tabular,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: CapsLabel('today', color: c.zoneInkMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${stats.pickupsWeek} in the last seven days · '
            '${stats.pickupsAll} in all',
            style: AppTypography.caption.copyWith(
              color: c.zoneInkMuted,
              fontFeatures: AppTypography.tabular,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({required this.stats});

  final OverviewStats stats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.cardGap,
      runSpacing: AppSpacing.cardGap,
      children: [
        _Tile(
          label: 'Sessions',
          value: '${stats.sessionsCompleted}/${stats.sessionsCommitted}',
          note: 'finished vs committed',
        ),
        _Tile(
          label: 'Errands',
          value: '${stats.errands}',
          note: 'a call, a message',
        ),
        _Tile(
          label: 'Just browsing',
          value: '${stats.browsing}',
          note: 'admitted, never judged',
        ),
        _Tile(
          label: 'Follow-through',
          value: '${stats.kept} of ${stats.said}',
          note: 'predictions you kept',
        ),
        _Tile(
          label: 'Time reclaimed',
          value: '${stats.reclaimedMinutes}m',
          note: 'committed and spent',
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final width = (MediaQuery.sizeOf(context).width -
            AppSpacing.lg * 2 -
            AppSpacing.cardGap) /
        2;
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.fillSubtle,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CapsLabel(label),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headline.copyWith(
              color: c.ink,
              fontWeight: FontWeight.w300,
              fontFeatures: AppTypography.tabular,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(note,
              style: AppTypography.caption.copyWith(color: c.inkMuted)),
        ],
      ),
    );
  }
}
