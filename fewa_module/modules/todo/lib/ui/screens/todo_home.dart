import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:todo/ui/hooks/hook_zones.dart';
import 'package:todo/ui/layout/todo_scaffold.dart';
import 'package:todo/ui/widgets/stat_card.dart';
import 'package:todo/ui/widgets/task_item.dart';
import 'package:todo/src/data/todo_task_store.dart';

class TodoHome extends StatefulWidget {
  TodoHome({
    super.key,
    required this.calculationEvents,
    TodoTaskStore? taskStore,
  }) : _taskStore = taskStore;

  final ValueListenable<int> calculationEvents;
  final TodoTaskStore? _taskStore;

  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  late final TodoTaskStore _taskStore = widget._taskStore ?? TodoTaskStore();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _metadataController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _metadataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.calculationEvents,
      builder: (context, calcCount, _) {
        final theme = Theme.of(context);
        return ValueListenableBuilder<List<TodoTask>>(
          valueListenable: _taskStore.tasks,
          builder: (context, tasks, _) {
            return TodoScaffold(
              appBarActions: const _TodoAppBarHookSlot(),
              onAddTask: () => _openAddTaskSurface(context),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Dashboard', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  StatCard(
                    label: 'Calculation Events Today',
                    value: calcCount.toString(),
                  ),
                  const SizedBox(height: 8),
                  const _DashboardHookSlot(),
                  const SizedBox(height: 16),
                  Text(
                    'Task List',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.8),
                        height: 1,
                      );
                    },
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskItem(
                        title: task.title,
                        metadata: task.metadata,
                        completed: task.done,
                        onChanged: (value) {
                          if (value == null) return;
                          unawaited(
                            _taskStore.setTaskDone(index: index, done: value),
                          );
                        },
                        trailingAction: const SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openAddTaskSurface(BuildContext context) async {
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            24,
            16,
            24 + bottomInset,
          ),
          child: Material(
            color: theme.colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Task',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'Enter task title',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _metadataController,
                  decoration: const InputDecoration(
                    labelText: 'Metadata (optional)',
                    hintText: 'Add optional notes',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 40,
                  child: FilledButton(
                    onPressed: () {
                      final title = _titleController.text.trim();
                      if (title.isEmpty) return;

                      unawaited(
                        _taskStore.addTask(
                          title: title,
                          metadata: _metadataController.text.trim(),
                          done: false,
                        ),
                      );

                      _titleController.clear();
                      _metadataController.clear();
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Add Task'),
                  ),
                ),
              ],
            ),
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
    return const SizedBox.shrink();
  }
}

class _DashboardHookSlot extends StatelessWidget {
  const _DashboardHookSlot();

  @override
  Widget build(BuildContext context) {
    return const KeyedSubtree(
      key: ValueKey(TodoHookZones.dashboardCards),
      child: SizedBox.shrink(),
    );
  }
}
