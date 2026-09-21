import '../core/time/clock.dart';
import '../core/time/local_date.dart';
import 'models.dart';

bool isOverdue(Task task, {required Clock clock}) {
  if (task.status == TaskStatus.done || task.status == TaskStatus.cancelled) {
    return false;
  }

  switch (task.dueKind) {
    case DueKind.none:
      return false;
    case DueKind.date:
      final dueDate = task.dueDate;
      return dueDate != null &&
          LocalDate.fromDateTime(clock.now).compareTo(dueDate) > 0;
    case DueKind.datetime:
      final dueAt = task.dueAt;
      return dueAt != null && dueAt.isBefore(clock.now);
  }
}
