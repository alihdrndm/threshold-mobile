import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/unlock/doorkeeper.dart';
import '../../../core/unlock/phone.dart';
import '../../../core/widgets/caps_label.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../calendar_sync/presentation/sync_providers.dart';
import '../../ritual/presentation/ritual_providers.dart';
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
        _Section(
          title: 'The threshold',
          note: 'Unlock the phone after half an hour away and the ritual '
              'meets you; a quick unlock shows one of your quotes instead. '
              'Android asks one permission for the door to open itself.',
          child: const _ThresholdSection(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _Section(
          title: 'Quotes',
          note: 'Your own words only, for the ritual and the quick-unlock '
              'threshold. An empty reservoir shows nothing — a line the app '
              'chose for you would be exactly the borrowed sentiment this '
              'replaces.',
          child: const _QuotesEditor(),
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
  /// Which action is in flight ('connect' | 'sync' | 'disconnect'), so
  /// each chip can wear its own busy label instead of a shared flag.
  String? _busyAction;
  bool get _busy => _busyAction != null;
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

    Future<void> act(String name, Future<void> Function() action) async {
      if (_busy) return;
      setState(() {
        _busyAction = name;
        _error = null;
      });
      try {
        await action();
      } on Object catch (e) {
        setState(() => _error = '$e');
      } finally {
        if (mounted) setState(() => _busyAction = null);
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
                : () => act('connect', () =>
                    ref.read(calendarStatusProvider.notifier).connect()),
            child: _chip(c, _busy ? 'Opening your browser…' : 'Connect',
                working: _busy),
          ),
        ] else ...[
          // Wrap, not Row: a chip whose label grows while working
          // ('Disconnecting…' + spinner) flows to the next line instead
          // of walking off the screen.
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _chip(c, 'Connected', accent: true),
              PressableScale(
                onPressed: _busy
                    ? null
                    : () => act('sync', () =>
                        ref.read(calendarStatusProvider.notifier).syncNow()),
                child: _chip(
                  c,
                  _busyAction == 'sync' ? 'Syncing…' : 'Sync now',
                  working: _busyAction == 'sync',
                  dimmed: _busy && _busyAction != 'sync',
                ),
              ),
              PressableScale(
                onPressed: _busy
                    ? null
                    : () => act('disconnect', () => ref
                        .read(calendarStatusProvider.notifier)
                        .disconnect()),
                child: _chip(
                  c,
                  _busyAction == 'disconnect'
                      ? 'Disconnecting…'
                      : 'Disconnect',
                  working: _busyAction == 'disconnect',
                  dimmed: _busy && _busyAction != 'disconnect',
                ),
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

  /// [dimmed] is the visible half of "disabled" — a chip that merely stops
  /// responding looks identical, which reads as broken, not busy.
  /// [working] shows a small inline spinner beside the label.
  Widget _chip(ThresholdColors c, String label,
          {bool accent = false, bool dimmed = false, bool working = false}) =>
      AnimatedOpacity(
        duration: AppDurations.base,
        curve: Curves.ease,
        opacity: dimmed ? 0.45 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.full),
            border: Border.all(color: accent ? c.accent : c.borderSubtle),
            color: accent ? c.accent.withValues(alpha: 0.12) : c.fillSubtle,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (working) ...[
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: c.inkMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label,
                  style: AppTypography.body.copyWith(color: c.ink)),
            ],
          ),
        ),
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

/// The doorkeeper's controls: the one Android permission it needs, and the
/// switch that stands it down entirely.
class _ThresholdSection extends ConsumerStatefulWidget {
  const _ThresholdSection();

  @override
  ConsumerState<_ThresholdSection> createState() =>
      _ThresholdSectionState();
}

class _ThresholdSectionState extends ConsumerState<_ThresholdSection>
    with WidgetsBindingObserver {
  bool _hasPermission = false;
  bool _enabled = true;
  bool _canLock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the system settings page: re-read the grant.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final has = await Doorkeeper.hasOverlayPermission();
    final enabled = await Doorkeeper.enabled();
    final canLock = await Phone.canLock();
    if (mounted) {
      setState(() {
        _hasPermission = has;
        _enabled = enabled;
        _canLock = canLock;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_hasPermission) ...[
          Text(
            'Needs "Display over other apps" — the door cannot open itself '
            'without it.',
            style: AppTypography.caption.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          PressableScale(
            onPressed: () => Doorkeeper.requestOverlayPermission(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.full),
                border: Border.all(color: c.accent),
                color: c.accent.withValues(alpha: 0.12),
              ),
              child: Text('Grant permission',
                  style: AppTypography.body.copyWith(color: c.ink)),
            ),
          ),
        ] else
          PressableScale(
            onPressed: () async {
              if (_enabled) {
                await Doorkeeper.stop();
              } else {
                await Doorkeeper.start();
              }
              await _refresh();
            },
            child: Row(children: [
              Icon(
                _enabled
                    ? Icons.toggle_on_rounded
                    : Icons.toggle_off_outlined,
                size: 32,
                color: _enabled ? c.accent : c.inkMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _enabled
                    ? 'Standing at the door'
                    : 'The door stays closed',
                style: AppTypography.body.copyWith(color: c.ink),
              ),
            ]),
          ),
        const SizedBox(height: AppSpacing.lg),
        // "For nothing" needs one power: putting the screen back to sleep.
        Text(
          _canLock
              ? 'Threshold can lock the screen, so "For nothing" can put '
                  'the phone back down for you.'
              : '"For nothing" can lock the phone for you — Android asks '
                  'you to allow that once.',
          style: AppTypography.caption.copyWith(color: c.inkMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        PressableScale(
          onPressed: () async {
            if (_canLock) {
              await Phone.revokeLock();
            } else {
              await Phone.requestLock();
            }
            await _refresh();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.full),
              border: Border.all(
                  color: _canLock ? c.borderSubtle : c.accent),
              color: _canLock
                  ? c.fillSubtle
                  : c.accent.withValues(alpha: 0.12),
            ),
            child: Text(_canLock ? 'Take it back' : 'Allow locking',
                style: AppTypography.body.copyWith(color: c.ink)),
          ),
        ),
      ],
    );
  }
}

/// The reservoir, editable: your words in, your words out.
class _QuotesEditor extends ConsumerStatefulWidget {
  const _QuotesEditor();

  @override
  ConsumerState<_QuotesEditor> createState() => _QuotesEditorState();
}

class _QuotesEditorState extends ConsumerState<_QuotesEditor> {
  final _text = TextEditingController();
  final _author = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    _author.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    await ref.read(ritualRepositoryProvider).addQuote(
          text,
          author: _author.text.trim().isEmpty ? null : _author.text.trim(),
        );
    _text.clear();
    _author.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final quotes = ref.watch(quotesProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final q in quotes) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.body,
                        style:
                            AppTypography.body.copyWith(color: c.ink)),
                    if (q.author != null)
                      Text('— ${q.author}',
                          style: AppTypography.caption
                              .copyWith(color: c.inkMuted)),
                  ],
                ),
              ),
              PressableScale(
                onPressed: () => ref
                    .read(ritualRepositoryProvider)
                    .removeQuote(q.body),
                semanticLabel: 'Remove this quote',
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(Icons.close,
                      size: 14,
                      color: c.inkMuted.withValues(alpha: 0.75)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TextField(
          controller: _text,
          maxLength: 280,
          style: AppTypography.body.copyWith(color: c.ink),
          cursorColor: c.accent,
          decoration: InputDecoration(
            hintText: 'A line worth keeping',
            hintStyle: AppTypography.body.copyWith(color: c.inkMuted),
            counterText: '',
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
              borderSide:
                  BorderSide(color: c.accent.withValues(alpha: 0.65)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _author,
              style: AppTypography.caption.copyWith(color: c.ink),
              cursorColor: c.accent,
              decoration: InputDecoration(
                hintText: 'Who said it (optional)',
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
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PressableScale(
            onPressed: _add,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.full),
                border: Border.all(color: c.borderSubtle),
                color: c.fillSubtle,
              ),
              child: Text('Keep it',
                  style: AppTypography.body.copyWith(color: c.ink)),
            ),
          ),
        ]),
      ],
    );
  }
}
