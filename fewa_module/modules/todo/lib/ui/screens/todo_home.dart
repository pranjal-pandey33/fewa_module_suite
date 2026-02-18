import 'package:flutter/material.dart';
import 'package:todo/todo_module.dart';
import '../layout/todo_scaffold.dart';
import '../widgets/stat_card.dart';
import '../widgets/task_item.dart';

class TodoHome extends StatelessWidget {
  const TodoHome({super.key});

  static const List<_TodoTask> _tasks = [
    _TodoTask(
      title: 'Finalize invoicing sequence',
      metadata: 'Due in 2 days • High priority',
      completed: true,
    ),
    _TodoTask(
      title: 'Link calculation result #182 to task',
      metadata: 'Due in 4 days • Medium priority',
      completed: false,
    ),
    _TodoTask(
      title: 'Archive closed projects',
      metadata: 'No due date • Low priority',
      completed: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: TodoModule.projections.calcCount,
      builder: (context, calcCount, _) {
        return TodoScaffold(
          appBarActions: const _TodoAppBarHookSlot(),
          onAddTask: () => _openAddTaskSurface(context),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatCard(
                label: 'Calculation Events Today',
                value: calcCount.toString(),
              ),
              const SizedBox(height: 8),
              const _DashboardHookSlot(),
              const SizedBox(height: 24),
              Text(
                'Task List',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tasks.length,
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.8),
                    height: 1,
                  );
                  },
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return TaskItem(
                    title: task.title,
                    metadata: task.metadata,
                    completed: task.completed,
                    onChanged: (_) {},
+                    trailingAction: const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddTaskSurface(BuildContext context) async {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 768) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Task'),
            content: const Text(
              'Task creation surface will be connected in the next phase.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Task creation surface will be connected in the next phase.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      },
    );
  }
}

class _TodoAppBarHookSlot extends StatelessWidget {
  const _TodoAppBarHookSlot();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _DashboardHookSlot extends StatelessWidget {
  const _DashboardHookSlot();

  @override
  Widget build(BuildContext context) {
    return const KeyedSubtree(
      key: ValueKey('todo.dashboard.cards'),
      child: SizedBox.shrink(),
    );
  }
}

class _TodoTask {
  const _TodoTask({
    required this.title,
    required this.metadata,
    required this.completed,
  });

  final String title;
  final String metadata;
  final bool completed;
}
