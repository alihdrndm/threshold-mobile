import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/caps_label.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../tasks/domain/areas_syntax.dart';
import '../../tasks/domain/quadrant.dart';
import '../../tasks/presentation/providers.dart';
import '../../tasks/presentation/task_card.dart';

/// The board: five zones stacked for a phone (position no longer carries
/// the meaning, so "each zone's header and invitation carry it alone"),
/// a quick-add field with the #area syntax, search that reaches across
/// everything, the one notice line, and Done today at the foot.
class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  final _add = TextEditingController();
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _add.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _add.text.trim();
    if (raw.isEmpty) return;
    final repo = ref.read(taskRepositoryProvider);
    final notice = ref.read(noticeProvider.notifier);
    final areas = ref.read(areasProvider).value ?? const [];
    final parsed = parseTitle(raw, [for (final a in areas) a.name]);
    if (parsed.title.isEmpty) return;
    final areaUid = parsed.areaName == null
        ? null
        : areas.firstWhere((a) => a.name == parsed.areaName).uid;
    final uid = await repo.add(parsed.title, areaUid: areaUid);
    _add.clear();
    setState(() {});
    if (parsed.unknown != null) {
      // "a name that vanishes on Enter is a name the user thinks was saved."
      notice.say(
        'No area called \u{201C}${parsed.unknown}\u{201D} yet',
        actionLabel: 'Create ${parsed.unknown}',
        action: () async {
          final created =
              await repo.addArea(tidyAreaName(parsed.unknown!));
          await repo.setArea(uid, created);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final areas = ref.watch(areasProvider).value ?? const [];
    final notice = ref.watch(noticeProvider);
    final searching = _query.trim().isNotEmpty;

    // The `#` completions — never animated: a keyboard path.
    final caretTag = tagAtCaret(_add.text, _add.selection.baseOffset < 0
        ? _add.text.length
        : _add.selection.baseOffset);
    final suggestions = caretTag == null
        ? const <String>[]
        : suggestAreas(caretTag.partial, [for (final a in areas) a.name]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
          child: Column(
            children: [
              // Two fields, two verbs: "the wide one adds, the narrow one
              // finds. One field doing both would need a mode."
              _Field(
                controller: _add,
                hint: 'Add a task',
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              if (suggestions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    children: [
                      for (final name in suggestions.take(4)) ...[
                        PressableScale(
                          onPressed: () {
                            final text = _add.text;
                            final tag = caretTag!;
                            _add.text =
                                '${text.substring(0, tag.start)}#$name ';
                            _add.selection = TextSelection.collapsed(
                                offset: _add.text.length);
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadii.full),
                              border: Border.all(color: c.borderSubtle),
                              color: c.fillSubtle,
                            ),
                            child: CapsLabel(name),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              _Field(
                controller: _search,
                hint: 'Search',
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: (_) {},
              ),
              if (notice != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: _NoticeLine(notice: notice),
                ),
            ],
          ),
        ),
        Expanded(
          child: searching ? _SearchResults(query: _query) : const _Zones(),
        ),
      ],
    );
  }
}

class _Zones extends ConsumerWidget {
  const _Zones();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doneToday = ref.watch(doneTodayProvider);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        for (final (i, q) in placeOrder.indexed) ...[
          _ArriveIn(index: i, child: _ZoneSection(quadrant: q)),
          const SizedBox(height: AppSpacing.zoneGap),
        ],
        if (doneToday.isNotEmpty)
          _ArriveIn(
              index: placeOrder.length, child: _DoneToday(tasks: doneToday)),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _ZoneSection extends ConsumerWidget {
  const _ZoneSection({required this.quadrant});

  final Quadrant quadrant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tasks = ref.watch(quadrantTasksProvider(quadrant));
    final zone = zoneFor(quadrant);
    final overCap =
        quadrant == Quadrant.doFirst && tasks.length > doFirstSoftCap;

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        HapticFeedback.selectionClick();
        ref.read(taskRepositoryProvider).moveToQuadrant(details.data, quadrant);
      },
      builder: (context, candidates, _) {
        final over = candidates.isNotEmpty;
        final wash = over
            ? Color.alphaBlend(c.ink.withValues(alpha: 0.05), c.zone(zone))
            : c.zone(zone);
        return AnimatedContainer(
          duration: AppDurations.base,
          curve: AppCurves.out,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            // The wash breathes toward the page at the bottom, so a zone
            // reads as a lit surface, not a flat swatch.
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                wash,
                Color.alphaBlend(c.surface.withValues(alpha: 0.35), wash),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.zone),
            border: Border.all(
              color: over ? c.accent : c.borderOn(zone),
            ),
          ),
          child: AnimatedSize(
            duration: AppDurations.notice,
            curve: AppCurves.out,
            alignment: Alignment.topCenter,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: '${quadrant.label} — ${quadrant.invitation}',
                header: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(quadrant.label.toUpperCase(),
                        style: AppTypography.zoneHeader
                            .copyWith(color: c.ink)),
                    if (tasks.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.sm),
                      // "The count is a mirror, not a meter" — only when
                      // non-zero, and worn as a quiet pill.
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: c.ink.withValues(alpha: 0.06),
                          borderRadius:
                              BorderRadius.circular(AppRadii.full),
                        ),
                        child: Text('${tasks.length}',
                            style: AppTypography.caption.copyWith(
                              color: c.zoneInkMuted,
                              fontFeatures: AppTypography.tabular,
                            )),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (tasks.isEmpty)
                Text(quadrant.invitation,
                    style: AppTypography.caption
                        .copyWith(color: c.zoneInkMuted))
              else ...[
                for (final (i, t) in tasks.indexed) ...[
                  TaskCard(task: t, ordinal: i + 1),
                  if (i < tasks.length - 1)
                    const SizedBox(height: AppSpacing.cardGap),
                ],
                if (overCap) ...[
                  const SizedBox(height: AppSpacing.sm),
                  // "Calm, inline, and not a warning."
                  Text('Four things cannot all be first. Move one?',
                      style:
                          AppTypography.caption.copyWith(color: c.ink)),
                ],
              ],
            ],
            ),
          ),
        );
      },
    );
  }
}

/// The board's once-per-open entrance: each zone fades in and rises 8px,
/// 40ms apart (capped) on the house curve. Occasional-tier motion — it
/// runs when the screen mounts, never on rebuilds — and reduced motion
/// skips the travel entirely.
class _ArriveIn extends StatefulWidget {
  const _ArriveIn({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_ArriveIn> createState() => _ArriveInState();
}

class _ArriveInState extends State<_ArriveIn>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(vsync: this, duration: AppDurations.cardIn);

  @override
  void initState() {
    super.initState();
    final delay = AppDurations.staggerStep * widget.index;
    final capped =
        delay > AppDurations.staggerCap ? AppDurations.staggerCap : delay;
    Future<void>.delayed(capped, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = AppCurves.out.transform(_controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - t)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _DoneToday extends StatelessWidget {
  const _DoneToday({required this.tasks});

  final List tasks;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.zone(Zone.done),
        borderRadius: BorderRadius.circular(AppRadii.zone),
        border: Border.all(color: c.borderOn(Zone.done)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CapsLabel('Done today · ${tasks.length}', size: 12, onZone: true),
          const SizedBox(height: AppSpacing.sm),
          for (final t in tasks) ...[
            TaskCard(task: t),
            const SizedBox(height: AppSpacing.cardGap),
          ],
        ],
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    // "Search reaches across everything - every zone, the Done pile, and
    // past any context filter."
    final all = ref.watch(tasksProvider).value ?? const [];
    final q = query.trim().toLowerCase();
    final hits = [
      for (final t in all)
        if (t.title.toLowerCase().contains(q)) t,
    ]..sort((a, b) =>
        placeIndex(a.quadrant, a.status).compareTo(
            placeIndex(b.quadrant, b.status)));

    if (hits.isEmpty) {
      return Center(
        child: Text('Nothing matches \u{201C}$query\u{201D}.',
            style: AppTypography.body.copyWith(color: c.inkMuted)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            hits.length == 1 ? 'One match' : '${hits.length} matches',
            style: AppTypography.caption.copyWith(color: c.inkMuted),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final t in hits) ...[
          TaskCard(task: t, showPlace: true),
          const SizedBox(height: AppSpacing.cardGap),
        ],
      ],
    );
  }

  static int placeIndex(Quadrant q, status) =>
      status.toString().endsWith('done')
          ? placeOrder.length
          : placeOrder.indexOf(q);
}

class _NoticeLine extends ConsumerWidget {
  const _NoticeLine({required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return AnimatedOpacity(
      // Self-dismissal fades; user-triggered removal is instant.
      duration: AppDurations.cardIn,
      curve: AppCurves.out,
      opacity: notice.leaving ? 0 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: c.fillSubtle,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: c.borderSubtle),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(notice.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTypography.body.copyWith(color: c.inkMuted)),
            ),
            if (notice.actionLabel != null)
              PressableScale(
                onPressed: () async {
                  ref.read(noticeProvider.notifier).clear();
                  await notice.action?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(
                        color: c.ink.withValues(alpha: 0.16)),
                  ),
                  child: Text(notice.actionLabel!,
                      style: AppTypography.caption
                          .copyWith(color: c.ink)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: AppTypography.body.copyWith(color: c.ink),
      cursorColor: c.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(color: c.inkMuted),
        isDense: true,
        filled: true,
        fillColor: c.fillSubtle,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
          borderSide: BorderSide(color: c.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
          borderSide:
              BorderSide(color: c.accent.withValues(alpha: 0.65)),
        ),
      ),
    );
  }
}
