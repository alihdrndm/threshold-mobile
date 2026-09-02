import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ritual/data/ritual_repository.dart';
import '../../ritual/presentation/ritual_providers.dart';

/// Recomputed on demand rather than watched: the record changes at the
/// threshold, not while you are reading it, and a number that moved under
/// the eye would be a scoreboard.
final overviewStatsProvider = FutureProvider<OverviewStats>(
    (ref) => ref.watch(ritualRepositoryProvider).stats());
