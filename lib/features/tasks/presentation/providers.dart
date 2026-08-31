import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../data/task_repository.dart';
import '../domain/quadrant.dart';
import '../domain/task.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository(ref.watch(databaseProvider)));

final tasksProvider = StreamProvider<List<Task>>(
    (ref) => ref.watch(taskRepositoryProvider).watchAll());

final areasProvider = StreamProvider<List<Area>>(
    (ref) => ref.watch(taskRepositoryProvider).watchAreas());

final settingsProvider = StreamProvider<Map<String, String>>(
    (ref) => ref.watch(taskRepositoryProvider).watchSettings());

/// Open tasks of one quadrant, in board order.
final quadrantTasksProvider =
    Provider.family<List<Task>, Quadrant>((ref, q) {
  final tasks = ref.watch(tasksProvider).value ?? const [];
  return [
    for (final t in tasks)
      if (t.isOpen && t.quadrant == q) t,
  ];
});

/// Tasks completed today — they leave the grid entirely; "a checkmark is
/// the reward."
final doneTodayProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? const [];
  final now = DateTime.now();
  return [
    for (final t in tasks)
      if (t.status == TaskStatus.done && t.completedTs != null)
        if (_sameDay(DateTime.tryParse(t.completedTs!), now)) t,
  ];
});

bool _sameDay(DateTime? a, DateTime b) =>
    a != null && a.year == b.year && a.month == b.month && a.day == b.day;

/// "One quiet line for things that went right, with at most one thing to
/// press." Self-dismissal fades (the flag flips 180ms before removal);
/// replacement is instant.
class Notice {
  const Notice(this.text, {this.actionLabel, this.action, this.leaving = false});
  final String text;
  final String? actionLabel;
  final Future<void> Function()? action;
  final bool leaving;
}

final noticeProvider =
    NotifierProvider<NoticeNotifier, Notice?>(NoticeNotifier.new);

class NoticeNotifier extends Notifier<Notice?> {
  Timer? _leave;
  Timer? _remove;

  @override
  Notice? build() {
    ref.onDispose(() {
      _leave?.cancel();
      _remove?.cancel();
    });
    return null;
  }

  void say(String text,
      {String? actionLabel, Future<void> Function()? action}) {
    _leave?.cancel();
    _remove?.cancel();
    state = Notice(text, actionLabel: actionLabel, action: action);
    _leave = Timer(const Duration(milliseconds: 5820), () {
      final s = state;
      if (s != null) {
        state = Notice(s.text,
            actionLabel: s.actionLabel, action: s.action, leaving: true);
      }
    });
    _remove = Timer(const Duration(milliseconds: 6000), clear);
  }

  /// Removal the user asked for is instant.
  void clear() {
    _leave?.cancel();
    _remove?.cancel();
    state = null;
  }
}
