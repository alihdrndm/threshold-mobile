import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../tasks/presentation/providers.dart';
import '../data/ritual_repository.dart';

final ritualRepositoryProvider = Provider<RitualRepository>(
    (ref) => RitualRepository(ref.watch(databaseProvider)));

final quotesProvider = StreamProvider<List<QuoteRow>>(
    (ref) => ref.watch(ritualRepositoryProvider).watchQuotes());

/// The session currently running, for the board banner and the chronometer.
final runningSessionProvider = StreamProvider<SessionRow?>(
    (ref) => ref.watch(ritualRepositoryProvider).watchRunning());
