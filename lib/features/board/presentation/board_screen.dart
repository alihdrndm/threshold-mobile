import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/pressable_scale.dart';

/// M0 placeholder: the board rendered from the token system with demo
/// content, so the design system can be judged on-device before the domain
/// lands in M1. Every value here comes from core/theme; the zone copy is
/// the product's own.
class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  static const _zones = [
    (Zone.inbox, 'Inbox', 'New tasks land here'),
    (Zone.doFirst, 'Do First', 'For what cannot wait'),
    (Zone.schedule, 'Schedule', 'For what deserves a date'),
    (Zone.delegate, 'Delegate or shrink', 'For what someone else can carry'),
    (Zone.eliminate, 'Eliminate', 'For what you can let go'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        for (final (zone, label, invitation) in _zones) ...[
          _ZoneSection(
            zone: zone,
            label: label,
            invitation: invitation,
            demoTitles: switch (zone) {
              Zone.doFirst => const ['Design system on a real screen'],
              Zone.schedule => const ['French — TEF/TCF prep ↻'],
              _ => const <String>[],
            },
          ),
          const SizedBox(height: AppSpacing.zoneGap),
        ],
        Center(
          child: Text(
            'Demo content — the board arrives with M1.',
            style: AppTypography.caption.copyWith(color: c.inkMuted),
          ),
        ),
      ],
    );
  }
}

class _ZoneSection extends StatelessWidget {
  const _ZoneSection({
    required this.zone,
    required this.label,
    required this.invitation,
    required this.demoTitles,
  });

  final Zone zone;
  final String label;
  final String invitation;
  final List<String> demoTitles;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dashed = zone == Zone.inbox;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.zone(zone),
        borderRadius: BorderRadius.circular(AppRadii.zone),
        border: Border.all(
          color: c.borderOn(zone),
          // Dashed carries one meaning app-wide: "not settled". Flutter has
          // no dashed Border; M1 brings the painter. The tint stands in.
          width: dashed ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.zoneHeader.copyWith(color: c.ink),
              ),
              if (demoTitles.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${demoTitles.length}',
                  style: AppTypography.caption.copyWith(
                    color: c.zoneInkMuted,
                    fontFeatures: AppTypography.tabular,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (demoTitles.isEmpty)
            Text(
              invitation,
              style: AppTypography.caption.copyWith(color: c.zoneInkMuted),
            )
          else
            for (final title in demoTitles) ...[
              _DemoCard(zone: zone, title: title),
              const SizedBox(height: AppSpacing.cardGap),
            ],
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.zone, required this.title});

  final Zone zone;
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final light = c.brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: c.cardOn(zone),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: c.borderOn(zone)),
        boxShadow: light
            ? const [
                BoxShadow(
                  color: Color(0x0D000000),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: c.zoneInkMuted.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(title, style: AppTypography.taskTitle.copyWith(color: c.ink)),
          ),
          const SizedBox(width: AppSpacing.md),
          PressableScale(
            onPressed: () {},
            semanticLabel: 'Focus on $title',
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.full),
                border: Border.all(
                  color: c.ink.withValues(alpha: 0.16),
                ),
              ),
              child: Text(
                'Focus',
                style: AppTypography.caption.copyWith(color: c.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
