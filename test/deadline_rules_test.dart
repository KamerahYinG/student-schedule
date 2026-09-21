import 'package:flutter_test/flutter_test.dart';
import 'package:student_schedule/core/time/clock.dart';
import 'package:student_schedule/core/time/local_date.dart';
import 'package:student_schedule/domain/deadline_rules.dart';
import 'package:student_schedule/domain/models.dart';

Task task({
  TaskStatus status = TaskStatus.todo,
  DueKind dueKind = DueKind.none,
  LocalDate? dueDate,
  DateTime? dueAt,
}) {
  final now = DateTime(2026, 10, 16, 12);
  return Task(
    id: 'task',
    title: 'Task',
    status: status,
    isInbox: false,
    dueKind: dueKind,
    dueDate: dueDate,
    dueAt: dueAt,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final now = FixedClock(DateTime(2026, 10, 16, 12));

  test('LocalDate has no time semantics and compares by calendar date', () {
    expect(LocalDate(2026, 10, 16), LocalDate(2026, 10, 16));
    expect(LocalDate(2026, 10, 16).compareTo(LocalDate(2026, 10, 17)),
        lessThan(0));
    expect(LocalDate.fromDateTime(DateTime(2026, 10, 16, 23, 59)),
        LocalDate(2026, 10, 16));
    expect(LocalDate(2026, 10, 16).toString(), '2026-10-16');
  });

  test('date-only deadline is not overdue during the due date', () {
    expect(
        isOverdue(task(dueKind: DueKind.date, dueDate: LocalDate(2026, 10, 16)),
            clock: now),
        isFalse);
  });

  test('date-only deadline is overdue only after the due date', () {
    final clock = FixedClock(DateTime(2026, 10, 17));
    expect(
        isOverdue(task(dueKind: DueKind.date, dueDate: LocalDate(2026, 10, 16)),
            clock: clock),
        isTrue);
  });

  test('datetime deadline is overdue strictly after dueAt', () {
    final dueAt = DateTime(2026, 10, 16, 12);
    expect(isOverdue(task(dueKind: DueKind.datetime, dueAt: dueAt), clock: now),
        isFalse);
    expect(
        isOverdue(
            task(
                dueKind: DueKind.datetime,
                dueAt: dueAt.subtract(const Duration(minutes: 1))),
            clock: now),
        isTrue);
  });

  test('done and cancelled tasks are never overdue', () {
    final overdue = DateTime(2026, 10, 15);
    expect(
        isOverdue(
            task(
                status: TaskStatus.done,
                dueKind: DueKind.datetime,
                dueAt: overdue),
            clock: now),
        isFalse);
    expect(
        isOverdue(
            task(
                status: TaskStatus.cancelled,
                dueKind: DueKind.date,
                dueDate: LocalDate(2026, 10, 15)),
            clock: now),
        isFalse);
  });
}
