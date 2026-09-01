import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/caps_label.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../calendar_sync/presentation/sync_providers.dart';
import '../../tasks/domain/areas_syntax.dart';
import '../../tasks/presentation/providers.dart';

/// "Everything here is editable on purpose. Self-set limits are the ones
/// people keep." Every section carries a prose note — this is where the
/// app does its explaining. Settings write through as they change.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? const {};
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _Section(
          title: 'Appearance',
          note:
              'Light, dark, or whatever the system is doing. The ritual will '
              'stay dark either way.',
          child: _AppearancePills(current: settings['appearance'] ?? 'system'),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _Section(
          title: 'Areas',
          note: 'Eight at most: past that they stop being areas and start '
              'being tags. Removing one leaves its tasks in place, unlabelled.',
          child: const _AreasEditor(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _Section(
          title: 'Google Calendar',
          note: 'Connect your own Google account and the week fills with '
              'your calendar — including events made on your phone or the '
              'web. Threshold uses your own OAuth client; nothing is shared '
              'with anyone else.',
          child: const _GoogleSection(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _Section(
          title: 'Working hours',
          note: 'When a task dropped into Schedule may be booked, once the '
              'calendar connects. The repeat roll-forward uses these too.',
          child: _WorkingHours(settings: settings),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Everything above lives on this phone only, until you connect '
          'Google Calendar.',
          style: AppTypography.caption
              .copyWith(color: context.colors.inkMuted),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.note, required this.child});

  final String title;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTypography.body
                .copyWith(color: c.ink, fontWeight: FontWeight.w500)),
        const SizedBox(height: AppSpacing.xs),
        Text(note,
            style: AppTypography.caption.copyWith(color: c.inkMuted)),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

class _GoogleSection extends ConsumerStatefulWidget {
  const _GoogleSection();

  @override
  ConsumerState<_GoogleSection> createState() => _GoogleSectionState();
}

class _GoogleSectionState extends ConsumerState<_GoogleSection> {
  final _clientId = TextEditingController();
  String? _error;
  bool _busy = false;
  bool _seeded = false;

  @override
  void dispose() {
    _clientId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final settings = ref.watch(settingsProvider).value ?? const {};
    final status = ref.watch(calendarStatusProvider).value;
    final repo = ref.read(taskRepositoryProvider);
    if (!_seeded && (settings['google_client_id'] ?? '').isNotEmpty) {
      _clientId.text = settings['google_client_id']!;
      _seeded = true;
    }

    Future<void> act(Future<void> Function() action) async {
      if (_busy) return;
      setState(() {
        _busy = true;
        _error = null;
      });
      try {
        await action();
      } on Object catch (e) {
        setState(() => _error = '$e');
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (status == null || !status.connected) ...[
          TextField(
            controller: _clientId,
            style: AppTypography.caption.copyWith(color: c.ink),
            decoration: InputDecoration(
              hintText: 'Android OAuth client ID (yours is built in)',
              hintStyle:
                  AppTypography.caption.copyWith(color: c.inkMuted),
              isDense: true,
              filled: true,
              fillColor: c.fillSubtle,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.item),
                borderSide: BorderSide(color: c.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.item),
                borderSide: BorderSide(
                    color: c.accent.withValues(alpha: 0.65)),
              ),
            ),
            onChanged: (v) => repo.setSetting('google_client_id', v.trim()),
          ),
          const SizedBox(height: AppSpacing.md),
          PressableScale(
            onPressed: _busy
                ? null
                : () => act(() =>
                    ref.read(calendarStatusProvider.notifier).connect()),
            child: _chip(c, _busy ? 'Opening your browser…' : 'Connect'),
          ),
        ] else ...[
          Row(
            children: [
              _chip(c, 'Connected', accent: true),
              const SizedBox(width: AppSpacing.sm),
              PressableScale(
                onPressed: () => act(() =>
                    ref.read(calendarStatusProvider.notifier).syncNow()),
                child: _chip(c, 'Sync now'),
              ),
              const SizedBox(width: AppSpacing.sm),
              PressableScale(
                onPressed: () => act(() => ref
                    .read(calendarStatusProvider.notifier)
                    .disconnect()),
                child: _chip(c, 'Disconnect'),
              ),
            ],
          ),
        ],
        if ((settings['google_last_sync_status'] ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('Last sync: ${settings['google_last_sync_status']}',
              style: AppTypography.caption.copyWith(color: c.inkMuted)),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: c.errorFill,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: c.errorBorder),
            ),
            child: Text(_error!,
                style: AppTypography.caption.copyWith(color: c.ink)),
          ),
        ],
      ],
    );
  }

  Widget _chip(ThresholdColors c, String label, {bool accent = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(color: accent ? c.accent : c.borderSubtle),
          color: accent ? c.accent.withValues(alpha: 0.12) : c.fillSubtle,
        ),
        child:
            Text(label, style: AppTypography.body.copyWith(color: c.ink)),
      );
}

class _AppearancePills extends ConsumerWidget {
  const _AppearancePills({required this.current});

  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final option in const ['system', 'light', 'dark'])
          PressableScale(
            onPressed: () => ref
                .read(taskRepositoryProvider)
                .setSetting('appearance', option),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.full),
                border: Border.all(
                    color: current == option ? c.accent : c.borderSubtle),
                color: current == option
                    ? c.accent.withValues(alpha: 0.12)
                    : c.fillSubtle,
              ),
              child: Text(
                option[0].toUpperCase() + option.substring(1),
                style: AppTypography.body.copyWith(color: c.ink),
              ),
            ),
          ),
      ],
    );
  }
}

class _AreasEditor extends ConsumerStatefulWidget {
  const _AreasEditor();

  @override
  ConsumerState<_AreasEditor> createState() => _AreasEditorState();
}

class _AreasEditorState extends ConsumerState<_AreasEditor> {
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final areas = ref.watch(areasProvider).value ?? const [];
    final repo = ref.read(taskRepositoryProvider);
    final notice = ref.read(noticeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final a in areas)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(a.name,
                      style: AppTypography.body.copyWith(color: c.ink)),
                ),
                PressableScale(
                  onPressed: () async {
                    final wearing = await repo.removeArea(a.uid);
                    notice.say(
                      wearing.isEmpty
                          ? 'Removed \u{201C}${a.name}\u{201D}'
                          : 'Removed \u{201C}${a.name}\u{201D} — '
                              '${wearing.length} task'
                              '${wearing.length == 1 ? '' : 's'} now '
                              'without an area',
                      actionLabel: 'Undo',
                      action: () async {
                        final restored = await repo.addArea(a.name);
                        for (final uid in wearing) {
                          await repo.setArea(uid, restored);
                        }
                      },
                    );
                  },
                  semanticLabel: 'Remove ${a.name}',
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child:
                        Icon(Icons.close, size: 14, color: c.inkMuted),
                  ),
                ),
              ],
            ),
          ),
        if (areas.length < maxAreas)
          TextField(
            controller: _field,
            style: AppTypography.body.copyWith(color: c.ink),
            decoration: InputDecoration(
              hintText: 'New area',
              hintStyle:
                  AppTypography.body.copyWith(color: c.inkMuted),
              isDense: true,
              filled: true,
              fillColor: c.fillSubtle,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.full),
                borderSide: BorderSide(color: c.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.full),
                borderSide: BorderSide(
                    color: c.accent.withValues(alpha: 0.65)),
              ),
            ),
            onSubmitted: (v) async {
              try {
                await repo.addArea(tidyAreaName(v));
                _field.clear();
              } on Object catch (e) {
                notice.say(e is FormatException
                    ? e.message
                    : e is StateError
                        ? e.message
                        : '$e');
              }
            },
          ),
      ],
    );
  }
}

class _WorkingHours extends ConsumerWidget {
  const _WorkingHours({required this.settings});

  final Map<String, String> settings;

  static const _names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final repo = ref.read(taskRepositoryProvider);
    final days = (settings['work_days'] ?? '1,2,3,4,5')
        .split(',')
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    final start = settings['work_start'] ?? '09:00';
    final end = settings['work_end'] ?? '18:00';

    Future<void> pick(String key, String current) async {
      final parts = current.split(':');
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 9,
            minute: int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0),
      );
      if (t == null) return;
      await repo.setSetting(key,
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var d = 1; d <= 7; d++)
              PressableScale(
                onPressed: () {
                  final next = {...days};
                  next.contains(d) ? next.remove(d) : next.add(d);
                  if (next.isEmpty) return;
                  repo.setSetting(
                      'work_days', (next.toList()..sort()).join(','));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(
                        color:
                            days.contains(d) ? c.accent : c.borderSubtle),
                    color: days.contains(d)
                        ? c.accent.withValues(alpha: 0.12)
                        : c.fillSubtle,
                  ),
                  child: Text(_names[d - 1],
                      style:
                          AppTypography.caption.copyWith(color: c.ink)),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const CapsLabel('Opens'),
            const SizedBox(width: AppSpacing.sm),
            PressableScale(
              onPressed: () => pick('work_start', start),
              child: _timeChip(c, start),
            ),
            const SizedBox(width: AppSpacing.lg),
            const CapsLabel('Closes'),
            const SizedBox(width: AppSpacing.sm),
            PressableScale(
              onPressed: () => pick('work_end', end),
              child: _timeChip(c, end),
            ),
          ],
        ),
      ],
    );
  }

  Widget _timeChip(ThresholdColors c, String value) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(color: c.borderSubtle),
          color: c.fillSubtle,
        ),
        child: Text(value,
            style: AppTypography.body.copyWith(
                color: c.ink, fontFeatures: AppTypography.tabular)),
      );
}
