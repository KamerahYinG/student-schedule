import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/time/clock.dart';
import '../../domain/models.dart';
import 'deadline_sections.dart';

class DeadlinesPage extends ConsumerWidget {
  const DeadlinesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(deadlineTasksProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (tasks) {
          final groups = groupDeadlineTasks(tasks, clock: SystemClock());
          return ListView(children: [
            Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Deadlines',
                    style: Theme.of(context).textTheme.headlineMedium)),
            ...groups.entries
                .where((entry) => entry.value.isNotEmpty)
                .map((entry) => ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(entry.key.name),
                    children: entry.value
                        .map((task) => ListTile(
                            title: Text(task.title),
                            subtitle: Text(task.dueKind.name),
                            leading: IconButton(
                                icon: const Icon(Icons.check_box_outline_blank),
                                onPressed: () => ref
                                    .read(taskRepositoryProvider)
                                    .save(Task(
                                        id: task.id,
                                        title: task.title,
                                        status: TaskStatus.done,
                                        isInbox: task.isInbox,
                                        dueKind: task.dueKind,
                                        dueDate: task.dueDate,
                                        dueAt: task.dueAt,
                                        sortOrder: task.sortOrder,
                                        createdAt: task.createdAt,
                                        updatedAt: DateTime.now())))))
                        .toList()))
                .toList()
          ]);
        },
      );
}
