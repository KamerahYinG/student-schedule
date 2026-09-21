import 'models.dart';

class ProjectProgress {
  const ProjectProgress({required this.completed, required this.total});

  final int completed;
  final int total;
}

ProjectProgress projectProgress(String projectId, Iterable<Task> tasks) {
  final projectTasks = tasks
      .where((task) => task.projectId == projectId && task.deletedAt == null)
      .toList();
  final parentIds =
      projectTasks.map((task) => task.parentTaskId).whereType<String>().toSet();
  final leaves = projectTasks.where((task) => !parentIds.contains(task.id));
  final eligible = leaves.where((task) => task.status != TaskStatus.cancelled);
  final eligibleList = eligible.toList();
  return ProjectProgress(
    completed:
        eligibleList.where((task) => task.status == TaskStatus.done).length,
    total: eligibleList.length,
  );
}
