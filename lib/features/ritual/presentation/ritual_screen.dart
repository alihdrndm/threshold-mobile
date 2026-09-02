import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/theme.dart';
import '../../../core/unlock/phone.dart';
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

enum _Step { arrival, intention, prediction, ifthen, commit, confirm, browsing }

/// The words the user chose to meet at the honourable exit.
///
/// Not the app moralising — the same rule the quote reservoir runs on: a
/// line you picked yourself is not the app talking, and it is doing a
/// different job. Set exactly as given; only the line breaks are ours,
/// because the five are five and the eye should see them that way.
const _browsingLeadIn =
    'Narrated Ibn Abbas, who said: The Messenger of '
    'Allah \u{FDFA} said to a man while advising him:';
const _browsingSaying = 'Take advantage of five things before they’re gone:';
const _browsingFive = [
  'your youth before your old age,',
  'your health before your illness,',
  'your wealth before your poverty,',
  'your free time before you become occupied,',
  'and your life before your death.',
];
const _browsingSource = 'Al-Mustadrak ‘ala al-Sahihayn (7846)';

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
  Timer? _confirmTimer;

  /// The screen on its way out, so the lock lands on darkness we caused.
  bool _dimming = false;

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
    _confirmTimer?.cancel();
    _intention.dispose();
    _ifThen.dispose();
    super.dispose();
  }

  void _advance(_Step next) => setState(() => _step = next);

  /// The honourable exit: recorded first, so the record is the same
  /// whether or not the words are read, and no blocks stand behind them.
  Future<void> _browse() async {
    await ref.read(ritualRepositoryProvider).recordBrowsing();
    if (mounted) _advance(_Step.browsing);
  }

  /// The admission: picked up for nothing, put back down. Recorded first —
  /// the count is the point — then the screen dims and sleeps.
  ///
  /// One beat, three senses on it: the press, a soft knock, and the light
  /// going out. The dim is what makes the lock feel caused by the tap
  /// rather than coincidental with it.
  ///
  /// Deliberately a single tap and not a hold-to-confirm: this button
  /// exists to make an honest admission cheap. Charge two seconds for it
  /// and the phone gets put down with the home button instead, and the
  /// count — the whole reason the button is here — stops being true.
  Future<void> _forNothing() async {
    unawaited(HapticFeedback.lightImpact());
    await ref.read(ritualRepositoryProvider).recordPickup();
    if (!mounted) return;
    if (!MediaQuery.disableAnimationsOf(context)) {
      setState(() => _dimming = true);
      await Future<void>.delayed(AppDurations.notice);
    }
    if (mounted) context.pop();
    await Phone.lockNow();
  }

  /// A real errand. Recorded as one, so the pickup count keeps its meaning.
  Future<void> _errand(String what, Future<bool> Function() open) async {
    await ref.read(ritualRepositoryProvider).recordErrand(what);
    if (mounted) context.pop();
    await open();
  }

  Future<void> _commit() async {
    final repo = ref.read(ritualRepositoryProvider);
    await repo.beginSession(
      intentionText: _intention.text.trim().isEmpty
          ? null
          : _intention.text.trim(),
      ifThen: _ifThen.text.trim().isEmpty ? null : _ifThen.text.trim(),
      predictedYes: _predictedYes,
      durationMin: _minutes,
      taskUid: _taskUid,
      taskTitle: _taskTitle,
    );
    unawaited(HapticFeedback.mediumImpact());
    _advance(_Step.confirm);
    // Held and cancelled in dispose: a lock mid-confirm used to leave this
    // running, and it would pop whatever screen happened to be on top when
    // it fired.
    _confirmTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.surface,
      body: AnimatedOpacity(
        opacity: _dimming ? 0 : 1,
        duration: AppDurations.notice,
        curve: AppCurves.out,
        child: SafeArea(
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
                  _Step.browsing => _browsingStep(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---- steps ------------------------------------------------------------

  Widget _arrival() {
    // A Stack only here: the two errands live in the screen's corners,
    // out of the question's way but never hidden behind a menu.
    return Stack(
      children: [
        Positioned.fill(child: _arrivalColumn()),
        Positioned(
          left: 0,
          bottom: 0,
          child: _corner(
            Icons.call_rounded,
            'Call',
            () => _errand('Call', Phone.openDialer),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: _corner(
            Icons.chat_bubble_outline_rounded,
            'WhatsApp',
            () => _errand('WhatsApp', Phone.openWhatsApp),
          ),
        ),
      ],
    );
  }

  Widget _corner(IconData icon, String label, VoidCallback onTap) =>
      PressableScale(
        onPressed: onTap,
        semanticLabel: 'Open $label',
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: _inkMuted),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.caption.copyWith(color: _inkMuted),
              ),
            ],
          ),
        ),
      );

  Widget _arrivalColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _BreathingRing(accent: theme.accent, glow: theme.glow),
        const SizedBox(height: AppSpacing.xxl),
        // The door opens with the question, not a greeting — the user's
        // explicit call, on both apps.
        Text('What are you here for?', style: _display.copyWith(color: _ink)),
        if (_quote != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            _quote!.body,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: _inkMuted, height: 1.6),
          ),
          if (_quote!.author != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '— ${_quote!.author}',
              style: AppTypography.caption.copyWith(color: theme.accent),
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.xxl),
        // Three answers to the question above, in the order the truth
        // usually arrives: nothing, browsing, and — reached past both —
        // the commitment. Only Begin is a button, because only Begin is a
        // destination; the two ways out are words, and a border around a
        // way out would make it look like somewhere to go.
        _textAction(
          'For nothing',
          _forNothing,
          semantic: 'Picked it up for nothing — lock the phone again',
        ),
        _textAction('Just browsing today', _browse),
        const SizedBox(height: AppSpacing.lg),
        _primary('Begin', () => _advance(_Step.intention)),
      ],
    );
  }

  /// An honest way out, as words rather than furniture.
  ///
  /// No border, no fill — a border here would make an exit look like a
  /// destination. Small and tracked, in the label voice the rest of the
  /// app already speaks, so the two ways out read as quiet next to a
  /// sentence-case Begin.
  ///
  /// The press answers in the day's own colour: muted ink lights to the
  /// accent under the finger and cools back on release. The earlier
  /// version only lifted opacity on already-white text, which is a real
  /// change the eye simply cannot see — a colour shift can.
  Widget _textAction(String label, VoidCallback onTap, {String? semantic}) =>
      PressableScale.builder(
        onPressed: onTap,
        semanticLabel: semantic,
        builder: (context, pressed) => Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 11, horizontal: AppSpacing.lg),
          child: AnimatedDefaultTextStyle(
            duration: AppDurations.base,
            curve: Curves.ease,
            style: AppTypography.labelCaps(size: 11).copyWith(
              color: pressed ? theme.accent : _inkMuted,
            ),
            child: Text(label.toUpperCase(), textAlign: TextAlign.center),
          ),
        ),
      );

  Widget _intentionStep() {
    final typing = theme.intentionMode == IntentionMode.type;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(theme.intentionPrompt, style: _display.copyWith(color: _ink)),
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
                  }),
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
                },
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
        Text(
          RitualTheme.predictionPrompt,
          style: _display.copyWith(color: _ink),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
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
          ],
        ),
      ],
    );
  }

  Widget _ifThenStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(theme.ifThenPrompt, style: _display.copyWith(color: _ink)),
        const SizedBox(height: AppSpacing.xl),
        _chips([
          for (final d in _ifThenDefaults)
            (
              d,
              () {
                _ifThen.text = d;
                _advance(_Step.commit);
              },
            ),
        ]),
        const SizedBox(height: AppSpacing.lg),
        _field(_ifThen, hint: 'or in your own words…'),
        const SizedBox(height: AppSpacing.xxl),
        ListenableBuilder(
          listenable: _ifThen,
          builder: (_, _) => _primary(
            'Continue',
            _ifThen.text.trim().isEmpty ? null : () => _advance(_Step.commit),
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
        Text(theme.durationPrompt, style: _display.copyWith(color: _ink)),
        const SizedBox(height: AppSpacing.xl),
        if (chips)
          _chips([
            for (final m in const [25, 50, 90])
              ('$m min', () => setState(() => _minutes = m)),
          ], selectedLabel: '$_minutes min')
        else ...[
          Text(
            '$_minutes minutes',
            style: AppTypography.headline.copyWith(color: _ink),
          ),
          Slider(
            value: _minutes.clamp(10, 120).toDouble(),
            min: 10,
            max: 120,
            divisions: 22,
            activeColor: theme.accent,
            inactiveColor: theme.glow,
            onChanged: (v) => setState(() => _minutes = v.round()),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        // Self-set limits are the ones people keep: any number of minutes,
        // 1-120, however the theme offers its presets.
        Row(
          children: [
            Text(
              'or exactly',
              style: AppTypography.caption.copyWith(color: _inkMuted),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 72,
              child: TextField(
                keyboardType: TextInputType.number,
                maxLength: 3,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: _ink),
                cursorColor: theme.accent,
                decoration: InputDecoration(
                  hintText: 'min',
                  counterText: '',
                  hintStyle: AppTypography.caption.copyWith(color: _inkMuted),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.glow),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.accent),
                  ),
                ),
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 1) {
                    setState(() => _minutes = n.clamp(1, 120));
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'minutes',
              style: AppTypography.caption.copyWith(color: _inkMuted),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        _primary('Start $_minutes min', _commit),
      ],
    );
  }

  /// Where the honourable exit leads. No timer, no gate, nothing to
  /// dismiss past — the browsing is already recorded, and the way on is
  /// right there. Scrollable so a long text and a large type setting can
  /// both be read.
  Widget _browsingStep() {
    // Centred when it fits, scrolling when the type is large: a reading
    // screen should sit in the middle of the page, not fall out of the top
    // of it.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // The chain of narration, quiet: it places the words without
              // competing with them.
              Text(
                _browsingLeadIn,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: _inkMuted,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // The saying carries the weight of the screen — display size,
              // light, tracked in a touch as large text wants.
              Text(
                _browsingSaying,
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  height: 1.45,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Set as five short lines with air between them: they are
              // five parallel clauses, and stacked they read as verse
              // rather than as a sentence that ran long.
              for (final line in _browsingFive)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Text(
                    line,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: _ink.withValues(alpha: 0.92),
                      fontSize: 17,
                      height: 1.4,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                _browsingSource,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: theme.accent),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _textAction('Go on', () => context.pop()),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confirmStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline_rounded, size: 40, color: theme.accent),
        const SizedBox(height: AppSpacing.lg),
        Text('Committed.', style: _display.copyWith(color: _ink)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '$_minutes minutes. The check-in will find you.',
          style: AppTypography.caption.copyWith(color: _inkMuted),
        ),
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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: _ink),
        ),
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
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.body.copyWith(color: _ink),
      ),
    ),
  );

  Widget _field(
    TextEditingController controller, {
    bool autofocus = false,
    String? hint,
  }) => TextField(
    controller: controller,
    autofocus: autofocus,
    style: AppTypography.body.copyWith(color: _ink),
    cursorColor: theme.accent,
    decoration: InputDecoration(
      hintText: hint ?? '',
      hintStyle: AppTypography.body.copyWith(color: _inkMuted),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.glow),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.accent),
      ),
    ),
    onChanged: (_) => setState(() {}),
  );

  Widget _chips(List<(String, VoidCallback)> items, {String? selectedLabel}) =>
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final (label, onTap) in items)
            PressableScale(
              onPressed: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: label == selectedLabel
                      ? theme.accent.withValues(alpha: 0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: label == selectedLabel
                        ? theme.accent
                        : const Color(0x2EFFFFFF),
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(color: _ink),
                ),
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
