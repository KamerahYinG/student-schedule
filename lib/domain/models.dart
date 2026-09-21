import '../core/time/local_date.dart';

enum ProjectStatus { active, done, archived }

enum TaskStatus { todo, doing, waiting, done, cancelled }

enum DueKind { none, date, datetime }

class Project {
  const Project({
    required this.id,
    required this.title,
    this.description,
    this.categoryId,
    required this.status,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? categoryId;
  final ProjectStatus status;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

class Task {
  const Task({
    required this.id,
    required this.title,
    this.notes,
    this.projectId,
    this.parentTaskId,
    this.categoryId,
    required this.status,
    required this.isInbox,
    required this.dueKind,
    this.dueDate,
    this.dueAt,
    this.estimateMinutes,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.deletedAt,
  });

  final String id;
  final String title;
  final String? notes;
  final String? projectId;
  final String? parentTaskId;
  final String? categoryId;
  final TaskStatus status;
  final bool isInbox;
  final DueKind dueKind;
  final LocalDate? dueDate;
  final DateTime? dueAt;
  final int? estimateMinutes;
  final double sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? deletedAt;
}

class Event {
  const Event({
    required this.id,
    required this.title,
    this.notes,
    this.projectId,
    this.categoryId,
    required this.startAt,
    required this.endAt,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String title;
  final String? notes;
  final String? projectId;
  final String? categoryId;
  final DateTime startAt;
  final DateTime endAt;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Event copyWith({String? categoryId}) => Event(
        id: id,
        title: title,
        notes: notes,
        projectId: projectId,
        categoryId: categoryId ?? this.categoryId,
        startAt: startAt,
        endAt: endAt,
        location: location,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );
}

class TimeBlock {
  const TimeBlock({
    required this.id,
    required this.taskId,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String taskId;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final int color;
  final double sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

String? effectiveCategoryId(Task task, Project? project) =>
    task.categoryId ?? project?.categoryId;
