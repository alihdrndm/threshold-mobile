import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/pressable_scale.dart';
import 'ritual_providers.dart';

/// The full ritual: arrival → intention → prediction → if-then → commit →
/// confirm, plus the honourable exit. Always dark, themed by the day
/// (`ritualThemeFor`), and the prediction prompt never rotates. Ends in a
/// real session — the commitment is the product.
class RitualScreen extends ConsumerStatefulWidget {
  const RitualScreen({super.key});

  @override
  ConsumerState<RitualScreen> createState() => _RitualScreenState();
}

enum _Step { arrival, intention, prediction, ifthen, commit, confirm }

class _RitualScreenState extends ConsumerState<RitualScreen> {
  late final theme = ritualThemeFor(DateTime.now());

  _Step _step = _Step.arrival;
  QuoteRow? _quote;
  List<({String text, String? taskUid})> _suggestions = const [];

  final _intention = TextEditingController();
  String? _taskUid;
  String? _taskTitle;
  bool? _predictedYes;
  final _ifThen = TextEditingController();
  int _minutes = 50;

  static const _ifThenDefaults = [
    'take one breath and return to my task',
    'write the urge on the scratchpad',
    'stand up for thirty seconds',
  ];

  @override
  void initState() {
    super.initState();
    Future(() async {
      final repo = ref.read(ritualRepositoryProvider);
      final quote = await repo.randomQuote();
      final suggestions = await repo.intentionSuggestions();
      if (!mounted) return;
      setState(() {
        _quote = quote;
        _suggestions = suggestions;
      });
    });
  }

  @override
  void dispose() {
    _intention.dispose();
    _ifThen.dispose();
    super.dispose();
  }

  void _advance(_Step next) => setState(() => _step = next);

  Future<void> _browse() async {
    await ref.read(ritualRepositoryProvider).recordBrowsing();
    if (mounted) context.pop();
  }

  Future<void> _commit() async {
    final repo = ref.read(ritualRepositoryProvider);
    await repo.beginSession(
      intentionText:
          _intention.text.trim().isEmpty ? null : _intention.text.trim(),
      ifThen: _ifThen.text.trim().isEmpty ? null : _ifThen.text.trim(),
      predictedYes: _predictedYes,
      durationMin: _minutes,
      taskUid: _taskUid,
      taskTitle: _taskTitle,
    );
    unawaited(HapticFeedback.mediumImpact());
    _advance(_Step.confirm);
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: AnimatedSwitcher(
            duration: AppDurations.emphasis,
            switchInCurve: AppCurves.out,
            switchOutCurve: AppCurves.out,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.02),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: switch (_step) {
                _Step.arrival => _arrival(),
                _Step.intention => _intentionStep(),
                _Step.prediction => _predictionStep(),
                _Step.ifthen => _ifThenStep(),
                _Step.commit => _commitStep(),
                _Step.confirm => _confirmStep(),
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---- steps ------------------------------------------------------------

  Widget _arrival() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _BreathingRing(accent: theme.accent, glow: theme.glow),
        const SizedBox(height: AppSpacing.xxl),
        Text(theme.greeting,
            style: _display.copyWith(color: _ink)),
        if (_quote != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            _quote!.body,
            textAlign: TextAlign.center,
            style: AppTypography.body
                .copyWith(color: _inkMuted, height: 1.6),
          ),
          if (_quote!.author != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text('— ${_quote!.author}',
                style: AppTypography.caption.copyWith(color: theme.accent)),
          ],
        ],
        const SizedBox(height: AppSpacing.xxxl),
        _primary('Begin', () => _advance(_Step.intention)),
        const SizedBox(height: AppSpacing.lg),
        _quiet('Just browsing today', _browse),
      ],
    );
  }

  Widget _intentionStep() {
    final typing = theme.intentionMode == IntentionMode.type;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(theme.intentionPrompt,
            style: _display.copyWith(color: _ink)),
        const SizedBox(height: AppSpacing.xl),
        if (typing) ...[
          _field(_intention, autofocus: true),
          const SizedBox(height: AppSpacing.lg),
          if (_suggestions.isNotEmpty)
            _chips([
              for (final s in _suggestions)
                (
                  s.text,
                  () => setState(() {
                        _intention.text = s.text;
                        _taskUid = s.taskUid;
                        _taskTitle = s.taskUid == null ? null : s.text;
                      })
                ),
            ]),
        ] else ...[
          _chips([
            for (final s in _suggestions)
              (
                s.text,
                () {
                  _intention.text = s.text;
                  _taskUid = s.taskUid;
                  _taskTitle = s.taskUid == null ? null : s.text;
                  _advance(_Step.prediction);
                }
              ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _field(_intention, hint: 'Something else…'),
        ],
        const SizedBox(height: AppSpacing.xxl),
        ListenableBuilder(
          listenable: _intention,
          builder: (_, _) => _primary(
            'Continue',
            _intention.text.trim().isEmpty
                ? null
                : () => _advance(_Step.prediction),
          ),
        ),
      ],
    );
  }

  Widget _predictionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Never reworded, never pre-focused: the question is the mechanism.
        Text(RitualTheme.predictionPrompt,
            style: _display.copyWith(color: _ink)),
        const SizedBox(height: AppSpacing.xxl),
        Row(children: [
          Expanded(
            child: _primary('Yes', () {
              _predictedYes = true;
              _advance(_Step.ifthen);
            }),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _secondary('No', () {
              _predictedYes = false;
              _advance(_Step.ifthen);
            }),
          ),
        ]),
      ],
    );
  }

  Widget _ifThenStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(theme.ifThenPrompt,
            style: _display.copyWith(color: _ink)),
        const SizedBox(height: AppSpacing.xl),
        _chips([
          for (final d in _ifThenDefaults)
            (
              d,
              () {
                _ifThen.text = d;
                _advance(_Step.commit);
              }
            ),
        ]),
        const SizedBox(height: AppSpacing.lg),
        _field(_ifThen, hint: 'or in your own words…'),
        const SizedBox(height: AppSpacing.xxl),
        ListenableBuilder(
          listenable: _ifThen,
          builder: (_, _) => _primary(
            'Continue',
            _ifThen.text.trim().isEmpty
                ? null
                : () => _advance(_Step.commit),
          ),
        ),
      ],
    );
  }

  Widget _commitStep() {
    final chips = theme.durationMode == DurationMode.chips;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(theme.durationPrompt,
            style: _display.copyWith(color: _ink)),
        const SizedBox(height: AppSpacing.xl),
        if (chips)
          _chips([
            for (final m in const [25, 50, 90])
              (
                '$m min',
                () => setState(() => _minutes = m)
              ),
          ], selectedLabel: '$_minutes min')
        else ...[
          Text('$_minutes minutes',
              style: AppTypography.headline.copyWith(color: _ink)),
          Slider(
            value: _minutes.toDouble(),
            min: 10,
            max: 120,
            divisions: 22,
            activeColor: theme.accent,
            inactiveColor: theme.glow,
            onChanged: (v) => setState(() => _minutes = v.round()),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        _primary('Start', _commit),
      ],
    );
  }

  Widget _confirmStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline_rounded,
            size: 40, color: theme.accent),
        const SizedBox(height: AppSpacing.lg),
        Text('Committed.', style: _display.copyWith(color: _ink)),
        const SizedBox(height: AppSpacing.sm),
        Text('$_minutes minutes. The check-in will find you.',
            style: AppTypography.caption.copyWith(color: _inkMuted)),
      ],
    );
  }

  // ---- shared pieces ----------------------------------------------------

  static const _ink = Color(0xFFE8E9EB);
  static const _inkMuted = Color(0xFF8B8F96);
  TextStyle get _display => AppTypography.headline.copyWith(
        fontWeight: FontWeight.w300,
        fontSize: 26,
        height: 1.3,
      );

  Widget _primary(String label, VoidCallback? onTap) => PressableScale(
        onPressed: onTap,
        child: AnimatedOpacity(
          duration: AppDurations.base,
          curve: Curves.ease,
          opacity: onTap == null ? 0.4 : 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.accent.withValues(alpha: 0.16),
              border: Border.all(color: theme.accent),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: _ink)),
          ),
        ),
      );

  Widget _secondary(String label, VoidCallback onTap) => PressableScale(
        onPressed: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x2EFFFFFF)),
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: _ink)),
        ),
      );

  Widget _quiet(String label, VoidCallback onTap) => PressableScale(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(label,
              style: AppTypography.caption.copyWith(color: _inkMuted)),
        ),
      );

  Widget _field(TextEditingController controller,
          {bool autofocus = false, String? hint}) =>
      TextField(
        controller: controller,
        autofocus: autofocus,
        style: AppTypography.body.copyWith(color: _ink),
        cursorColor: theme.accent,
        decoration: InputDecoration(
          hintText: hint ?? '',
          hintStyle: AppTypography.body.copyWith(color: _inkMuted),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.glow)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.accent)),
        ),
        onChanged: (_) => setState(() {}),
      );

  Widget _chips(List<(String, VoidCallback)> items,
          {String? selectedLabel}) =>
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final (label, onTap) in items)
            PressableScale(
              onPressed: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: label == selectedLabel
                      ? theme.accent.withValues(alpha: 0.2)
                      : Colors.transparent,
                  border: Border.all(
                      color: label == selectedLabel
                          ? theme.accent
                          : const Color(0x2EFFFFFF)),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(label,
                    style: AppTypography.caption.copyWith(color: _ink)),
              ),
            ),
        ],
      );
}

/// The arrival's breathing ring: a 3-second cycle, "explicitly exempt from
/// the sub-300ms rule" — a breath made fast would defeat the point of it.
/// Reduced motion holds it still at full glow.
class _BreathingRing extends StatefulWidget {
  const _BreathingRing({required this.accent, required this.glow});

  final Color accent;
  final Color glow;

  @override
  State<_BreathingRing> createState() => _BreathingRingState();
}

class _BreathingRingState extends State<_BreathingRing>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppDurations.breath,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: widget.accent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.glow,
                blurRadius: 24 + 16 * t,
                spreadRadius: 2 + 6 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}
