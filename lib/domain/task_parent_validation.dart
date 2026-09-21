import 'models.dart';

bool isValidTaskParent({
  required Task task,
  required String? proposedParentTaskId,
  required Iterable<Task> tasks,
}) {
  if (proposedParentTaskId == null) return true;
  if (proposedParentTaskId == task.id) return false;

  final byId = {for (final candidate in tasks) candidate.id: candidate};
  String? ancestorId = proposedParentTaskId;
  final visited = <String>{};
  while (ancestorId != null && visited.add(ancestorId)) {
    if (ancestorId == task.id) return false;
    ancestorId = byId[ancestorId]?.parentTaskId;
  }
  return true;
}
