import 'package:drift/drift.dart';

import '../../domain/models.dart';
import '../../domain/repositories/task_repository.dart';
import '../local/app_database.dart';
import '../mappers/task_mapper.dart';

class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(this.database);
  final AppDatabase database;

  SimpleSelectStatement<$TaskRowsTable, TaskRow> _active() =>
      database.select(database.taskRows)
        ..where((row) => row.deletedAt.isNull());

  @override
  Stream<List<Task>> watchAll() => _active()
      .watch()
      .map((rows) => rows.map((row) => row.toDomain()).toList());

  @override
  Stream<List<Task>> watchInbox() =>
      (_active()..where((row) => row.isInbox.equals(true)))
          .watch()
          .map((rows) => rows.map((row) => row.toDomain()).toList());

  @override
  Stream<List<Task>> watchTasksWithDeadline() =>
      (_active()..where((row) => row.dueKind.isNotIn([DueKind.none.index])))
          .watch()
          .map((rows) => rows.map((row) => row.toDomain()).toList());

  @override
  Future<Task?> getById(String id) async =>
      (_active()..where((row) => row.id.equals(id)))
          .getSingleOrNull()
          .then((row) => row?.toDomain());

  @override
  Future<void> save(Task task) => database
      .into(database.taskRows)
      .insertOnConflictUpdate(taskCompanion(task));

  @override
  Future<void> delete(String id, DateTime deletedAt) =>
      (database.update(database.taskRows)..where((row) => row.id.equals(id)))
          .write(TaskRowsCompanion(
              deletedAt: Value(deletedAt), updatedAt: Value(deletedAt)));
}
