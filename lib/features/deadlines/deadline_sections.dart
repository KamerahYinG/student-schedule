import '../../core/time/clock.dart';
import '../../core/time/local_date.dart';
import '../../domain/deadline_rules.dart';
import '../../domain/models.dart';

enum DeadlineSection { overdue, today, next3Days, thisWeek, later }

Map<DeadlineSection, List<Task>> groupDeadlineTasks(Iterable<Task> tasks,
    {required Clock clock}) {
  final today = LocalDate.fromDateTime(clock.now);
  final result = {
    for (final section in DeadlineSection.values) section: <Task>[]
  };
  for (final task in tasks) {
    if (task.status == TaskStatus.done || task.status == TaskStatus.cancelled)
      continue;
    if (isOverdue(task, clock: clock)) {
      result[DeadlineSection.overdue]!.add(task);
      continue;
    }
    final date = task.dueKind == DueKind.date
        ? task.dueDate
        : LocalDate.fromDateTime(task.dueAt!);
    final days = (date!.year - today.year) * 365 +
        (date.month - today.month) * 31 +
        date.day -
        today.day;
    final section = days == 0
        ? DeadlineSection.today
        : days <= 3
            ? DeadlineSection.next3Days
            : date.month == today.month
                ? DeadlineSection.thisWeek
                : DeadlineSection.later;
    result[section]!.add(task);
  }
  for (final list in result.values) {
    list.sort((a, b) => _deadline(a).compareTo(_deadline(b)));
  }
  return result;
}

DateTime _deadline(Task task) => task.dueKind == DueKind.datetime
    ? task.dueAt!
    : DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
