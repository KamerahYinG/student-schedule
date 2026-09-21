import 'package:drift/drift.dart';

import '../../core/time/local_date.dart';
import '../../domain/models.dart';
import '../local/app_database.dart';

extension TaskRowMapper on TaskRow {
  Task toDomain() => Task(
        id: id,
        title: title,
        notes: notes,
        projectId: projectId,
        parentTaskId: parentTaskId,
        categoryId: categoryId,
        status: TaskStatus.values[status],
        isInbox: isInbox,
        dueKind: DueKind.values[dueKind],
        dueDate: dueDate == null ? null : _parseDate(dueDate!),
        dueAt: dueAt,
        estimateMinutes: estimateMinutes,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
        deletedAt: deletedAt,
      );
}

TaskRowsCompanion taskCompanion(Task task) => TaskRowsCompanion.insert(
      id: task.id,
      title: task.title,
      notes: Value(task.notes),
      projectId: Value(task.projectId),
      parentTaskId: Value(task.parentTaskId),
      categoryId: Value(task.categoryId),
      status: task.status.index,
      isInbox: task.isInbox,
      dueKind: task.dueKind.index,
      dueDate: Value(task.dueDate?.toString()),
      dueAt: Value(task.dueAt),
      estimateMinutes: Value(task.estimateMinutes),
      sortOrder: task.sortOrder,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      completedAt: Value(task.completedAt),
      deletedAt: Value(task.deletedAt),
    );

LocalDate _parseDate(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return LocalDate(parts[0], parts[1], parts[2]);
}
