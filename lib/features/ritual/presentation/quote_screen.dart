import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/theme.dart';
import 'ritual_providers.dart';

/// The quick-unlock threshold: one saved line, the day's ritual palette,
/// tap anywhere to pass through. It appears dozens of times a day, so its
/// motion is a bare 150ms fade — and an empty reservoir shows nothing at
/// all: the screen dismisses itself rather than serving borrowed words.
class QuoteScreen extends ConsumerStatefulWidget {
  const QuoteScreen({super.key});

  @override
  ConsumerState<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends ConsumerState<QuoteScreen> {
  QuoteRow? _quote;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final quote =
          await ref.read(ritualRepositoryProvider).randomQuote();
      if (!mounted) return;
      if (quote == null) {
        context.pop();
        return;
      }
      setState(() {
        _quote = quote;
        _loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ritualThemeFor(DateTime.now());
    final quote = _quote;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.pop(),
      child: Scaffold(
        backgroundColor: theme.surface,
        body: AnimatedOpacity(
          duration: AppDurations.base,
          curve: Curves.ease,
          opacity: _loaded ? 1 : 0,
          child: quote == null
              ? const SizedBox.expand()
              : SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            quote.body,
                            textAlign: TextAlign.center,
                            style: AppTypography.headline.copyWith(
                              color: const Color(0xFFE8E9EB),
                              fontWeight: FontWeight.w300,
                              height: 1.5,
                            ),
                          ),
                          if (quote.author != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              '— ${quote.author}',
                              style: AppTypography.caption.copyWith(
                                color: theme.accent,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xxxl),
                          Text(
                            'tap to continue',
                            style: AppTypography.caption.copyWith(
                              color: const Color(0x668B8F96),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
