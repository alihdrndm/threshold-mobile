import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/board/presentation/board_screen.dart';
import '../theme/theme.dart';
import '../widgets/caps_label.dart';

/// Four tabs in a stateful shell; fullscreen routes (/ritual, /checkin,
/// /reminder) join outside the shell in their milestones.
final appRouter = GoRouter(
  initialLocation: '/board',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _Shell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/board', builder: (_, _) => const BoardScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/week',
            builder: (_, _) => const _ComingSoon(
              'Week',
              'Nothing booked in the coming week.',
            ),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/overview',
            builder: (_, _) => const _ComingSoon(
              'Overview',
              'Nothing recorded yet.',
            ),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            builder: (_, _) => const _ComingSoon(
              'Settings',
              'Everything here will be editable on purpose.',
            ),
          ),
        ]),
      ],
    ),
  ],
);

class _Shell extends StatelessWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (Icons.grid_view_rounded, 'Board'),
    (Icons.calendar_view_week_rounded, 'Week'),
    (Icons.timeline_rounded, 'Overview'),
    (Icons.tune_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: AppSpacing.lg,
        title: Text(
          'Threshold',
          style: AppTypography.body.copyWith(
            color: c.ink,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.borderSubtle),
        ),
      ),
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => shell.goBranch(
                        i,
                        initialLocation: i == shell.currentIndex,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _tabs[i].$1,
                            size: 20,
                            color: i == shell.currentIndex ? c.ink : c.inkMuted,
                          ),
                          const SizedBox(height: 2),
                          CapsLabel(
                            _tabs[i].$2,
                            color: i == shell.currentIndex ? c.ink : c.inkMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The empty state speaks in the product's voice: an invitation, never a
/// mourning. Real screens replace these per milestone.
class _ComingSoon extends StatelessWidget {
  const _ComingSoon(this.title, this.line);

  final String title;
  final String line;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CapsLabel(title, size: 12),
          const SizedBox(height: AppSpacing.sm),
          Text(
            line,
            style: AppTypography.body.copyWith(color: c.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
