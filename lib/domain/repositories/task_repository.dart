import '../models.dart';

abstract interface class TaskRepository {
  Future<void> save(Task task);
  Future<Task?> getById(String id);
  Stream<List<Task>> watchAll();
  Stream<List<Task>> watchInbox();
  Stream<List<Task>> watchTasksWithDeadline();
  Future<void> delete(String id, DateTime deletedAt);
}
