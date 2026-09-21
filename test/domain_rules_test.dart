import 'package:flutter_test/flutter_test.dart';
import 'package:student_schedule/domain/category_inheritance.dart';
import 'package:student_schedule/domain/models.dart';
import 'package:student_schedule/domain/project_progress.dart';
import 'package:student_schedule/domain/task_parent_validation.dart';

final _time = DateTime(2026, 10, 16);

Task makeTask(
  String id, {
  String? projectId = 'project',
  String? parentTaskId,
  TaskStatus status = TaskStatus.todo,
  String? categoryId,
  DateTime? deletedAt,
}) =>
    Task(
      id: id,
      title: id,
      projectId: projectId,
      parentTaskId: parentTaskId,
      categoryId: categoryId,
      status: status,
      isInbox: false,
      dueKind: DueKind.none,
      sortOrder: 0,
      createdAt: _time,
      updatedAt: _time,
      deletedAt: deletedAt,
    );

Project makeProject({String? categoryId}) => Project(
      id: 'project',
      title: 'Project',
      categoryId: categoryId,
      status: ProjectStatus.active,
      createdAt: _time,
      updatedAt: _time,
    );

void main() {
  test('project progress counts eligible leaf tasks only', () {
    final tasks = [
      makeTask('parent', status: TaskStatus.done),
      makeTask('done', parentTaskId: 'parent', status: TaskStatus.done),
      makeTask('todo', parentTaskId: 'parent'),
      makeTask('cancelled', status: TaskStatus.cancelled),
      makeTask('deleted', deletedAt: _time),
      makeTask('other-project', projectId: 'other', status: TaskStatus.done),
    ];
    expect(projectProgress('project', tasks).completed, 1);
    expect(projectProgress('project', tasks).total, 2);
  });

  test('task and event categories inherit dynamically from project', () {
    final project = makeProject(categoryId: 'course');
    final task = makeTask('task');
    final ownCategoryTask = makeTask('own', categoryId: 'personal');
    final event = Event(
      id: 'event',
      title: 'Event',
      projectId: project.id,
      startAt: _time,
      endAt: _time.add(const Duration(hours: 1)),
      createdAt: _time,
      updatedAt: _time,
    );
    final ownCategoryEvent = Event(
      id: 'own-event',
      title: 'Event',
      categoryId: 'personal',
      startAt: _time,
      endAt: _time.add(const Duration(hours: 1)),
      createdAt: _time,
      updatedAt: _time,
    );
    expect(effectiveTaskCategoryId(task, project), 'course');
    expect(effectiveTaskCategoryId(ownCategoryTask, project), 'personal');
    expect(effectiveEventCategoryId(event, project), 'course');
    expect(effectiveEventCategoryId(ownCategoryEvent, project), 'personal');
    expect(task.categoryId, isNull);
  });

  test('task parent validation rejects self-parent and descendant cycles', () {
    final a = makeTask('a');
    final b = makeTask('b', parentTaskId: 'a');
    final c = makeTask('c', parentTaskId: 'b');
    final tasks = [a, b, c];
    expect(isValidTaskParent(task: a, proposedParentTaskId: 'a', tasks: tasks),
        isFalse);
    expect(isValidTaskParent(task: a, proposedParentTaskId: 'c', tasks: tasks),
        isFalse);
    expect(isValidTaskParent(task: c, proposedParentTaskId: null, tasks: tasks),
        isTrue);
    expect(isValidTaskParent(task: c, proposedParentTaskId: 'a', tasks: tasks),
        isTrue);
  });
}
