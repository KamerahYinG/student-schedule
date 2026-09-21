import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../domain/models.dart';

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () => _add(context, ref), child: const Icon(Icons.add)),
      body: ref.watch(inboxTasksProvider).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (tasks) => ListView(
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(24), child: Text('Inbox', style: Theme.of(context).textTheme.headlineMedium)),
            ...tasks.map((task) => ListTile(
              leading: Checkbox(value: task.status == TaskStatus.done, onChanged: (_) => _save(ref, task, status: TaskStatus.done)),
              title: Text(task.title),
              subtitle: task.dueKind == DueKind.none ? null : Text(_deadline(task)),
              onTap: () => _edit(context, ref, task),
              trailing: IconButton(icon: const Icon(Icons.archive_outlined), onPressed: () => _save(ref, task, isInbox: false)),
            )),
          ],
        ),
      ),
    );
  }
  Future<void> _add(BuildContext context, WidgetRef ref) => _edit(context, ref, null);
  Future<void> _edit(BuildContext context, WidgetRef ref, Task? task) async {
    final controller = TextEditingController(text: task?.title ?? '');
    await showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(task == null ? 'Add Task' : 'Edit Task'), content: TextField(controller: controller, autofocus: true), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { if (controller.text.trim().isNotEmpty) _save(ref, task ?? _new(controller.text.trim()), title: controller.text.trim()); Navigator.pop(context); }, child: const Text('Save'))]));
    controller.dispose();
  }
  Task _new(String title) { final now = DateTime.now(); return Task(id: 'task-${now.microsecondsSinceEpoch}', title: title, status: TaskStatus.todo, isInbox: true, dueKind: DueKind.none, sortOrder: 0, createdAt: now, updatedAt: now); }
  void _save(WidgetRef ref, Task task, {String? title, TaskStatus? status, bool? isInbox}) => ref.read(taskRepositoryProvider).save(Task(id: task.id, title: title ?? task.title, notes: task.notes, projectId: task.projectId, parentTaskId: task.parentTaskId, categoryId: task.categoryId, status: status ?? task.status, isInbox: isInbox ?? task.isInbox, dueKind: task.dueKind, dueDate: task.dueDate, dueAt: task.dueAt, estimateMinutes: task.estimateMinutes, sortOrder: task.sortOrder, createdAt: task.createdAt, updatedAt: DateTime.now(), completedAt: status == TaskStatus.done ? DateTime.now() : task.completedAt, deletedAt: task.deletedAt));
}

String _deadline(Task task) => task.dueKind == DueKind.date ? task.dueDate.toString() : task.dueAt.toString();
