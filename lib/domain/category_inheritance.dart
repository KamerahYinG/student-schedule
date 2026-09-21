import 'models.dart';

String? effectiveTaskCategoryId(Task task, Project? project) =>
    task.categoryId ?? project?.categoryId;

String? effectiveEventCategoryId(Event event, Project? project) =>
    event.categoryId ?? project?.categoryId;
