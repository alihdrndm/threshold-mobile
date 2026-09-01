import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../tasks/domain/quadrant.dart';
import '../../tasks/presentation/providers.dart';
import 'ritual_providers.dart';

/// The check-in: what actually happened, answered against what you said
/// would. Fires while a session awaits its answer; the 10-minute grace and
/// silent lapse live in the repository — by the time this screen shows,
/// the session has earned its question.
class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  SessionRow? _session;
  String? _intentionText;
  bool _taskStillOpen = false;
  bool _markDone = false;
  String? _answered; // completed | partly | missed → follow-up shown

  @override
  void initState() {
    super.initState();
    Future(() async {
      final repo = ref.read(ritualRepositoryProvider);
      final session = await repo.byId(widget.sessionId);
      if (!mounted) return;
      if (session == null || session.state != 'awaiting_checkin') {
        context.pop();
        return;
      }
      String? intentionText;
      final rows = await ref
          .read(databaseProvider)
          .customSelect(
            'SELECT text FROM intentions WHERE id = ?',
            variables: [Variable.withInt(session.intentionId)],
          )
          .get();
      if (rows.isNotEmpty) {
        intentionText = rows.first.read<String?>('text');
      }
      var open = false;
      if (session.taskUid != null) {
        final task =
            await ref.read(taskRepositoryProvider).byUid(session.taskUid!);
        open = task != null && task.status.name == 'open';
      }
      setState(() {
        _session = session;
        _intentionText = intentionText;
        _taskStillOpen = open;
      });
    });
  }

  Future<void> _answer(String state) async {
    final session = _session!;
    await ref
        .read(ritualRepositoryProvider)
        .answer(session.id, state, taskDone: _markDone);
    if (_markDone && session.taskUid != null) {
      await ref.read(taskRepositoryProvider).complete(session.taskUid!);
    }
    if (!mounted) return;
    if (state == 'completed') {
      context.pop();
    } else {
      setState(() => _answered = state);
    }
  }

  Future<void> _keepGoing(int minutes) async {
    final session = _session!;
    // Continue carries intention/task/title but NEVER the prediction —
    // "a prediction nobody re-made must not be re-scored."
    await ref.read(ritualRepositoryProvider).beginSession(
          intentionText: _intentionText,
          durationMin: minutes,
          taskUid: session.taskUid,
          taskTitle: session.taskTitle,
        );
    if (mounted) context.pop();
  }

  Future<void> _giveItADate() async {
    final uid = _session?.taskUid;
    if (uid != null) {
      await ref
          .read(taskRepositoryProvider)
          .moveToQuadrant(uid, Quadrant.schedule);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ritualThemeFor(DateTime.now());
    final session = _session;
    if (session == null) {
      return Scaffold(backgroundColor: theme.surface);
    }
    final elapsed = (((session.endedTs ?? session.endsTs) -
                session.startedTs) /
            60)
        .round()
        .clamp(0, session.durationMin);
    final subject =
        session.taskTitle ?? _intentionText ?? 'your intention';
    final predictionLine = switch (session.predictedYes) {
      1 => 'You thought you would.',
      0 => "You thought you wouldn't.",
      _ => 'No prediction on this one.',
    };

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$elapsed minutes on $subject.',
                style: AppTypography.headline.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w300,
                  fontSize: 26,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(predictionLine,
                  style:
                      AppTypography.caption.copyWith(color: _inkMuted)),
              const SizedBox(height: AppSpacing.xxl),
              if (_answered == null) ...[
                _button(theme, 'Did it', () => _answer('completed'),
                    primary: true),
                const SizedBox(height: AppSpacing.md),
                _button(theme, 'Partly', () => _answer('partly')),
                const SizedBox(height: AppSpacing.md),
                _button(
                    theme, 'Not this time', () => _answer('missed')),
                if (_taskStillOpen) ...[
                  const SizedBox(height: AppSpacing.xl),
                  PressableScale(
                    onPressed: () =>
                        setState(() => _markDone = !_markDone),
                    child: Row(children: [
                      Icon(
                        _markDone
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        size: 18,
                        color:
                            _markDone ? theme.accent : _inkMuted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Mark this task done',
                          style: AppTypography.caption
                              .copyWith(color: _inkMuted)),
                    ]),
                  ),
                ],
              ] else ...[
                Text(
                  _answered == 'partly'
                      ? "There's some left, then."
                      : 'Want another run at it?',
                  style: AppTypography.body.copyWith(color: _ink),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final m in const [25, 50, 90])
                      _chip(theme, '$m min', () => _keepGoing(m)),
                    if (_session?.taskUid != null)
                      _chip(theme, 'Give it a date', _giveItADate),
                    _chip(theme, 'Just note it',
                        () => context.pop()),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static const _ink = Color(0xFFE8E9EB);
  static const _inkMuted = Color(0xFF8B8F96);

  Widget _button(RitualTheme theme, String label, VoidCallback onTap,
          {bool primary = false}) =>
      PressableScale(
        onPressed: onTap,
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: primary
                ? theme.accent.withValues(alpha: 0.16)
                : Colors.transparent,
            border: Border.all(
                color: primary
                    ? theme.accent
                    : const Color(0x2EFFFFFF)),
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: _ink)),
        ),
      );

  Widget _chip(RitualTheme theme, String label, VoidCallback onTap) =>
      PressableScale(
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: theme.glow),
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          child: Text(label,
              style: AppTypography.caption.copyWith(color: _ink)),
        ),
      );
}
