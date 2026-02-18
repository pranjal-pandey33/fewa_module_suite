import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:todo/ui/hooks/hook_zones.dart';
import 'package:todo/ui/layout/todo_scaffold.dart';
import 'package:todo/ui/widgets/stat_card.dart';
import 'package:todo/ui/widgets/task_item.dart';
import 'package:todo/src/data/todo_task_store.dart';

class TodoHome extends StatefulWidget {
  const TodoHome({
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

  @override
  void initState() {
    super.initState();
    unawaited(_taskStore.init());
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.calculationEvents,
      builder: (context, calcCount, _) {
        final theme = Theme.of(context);
        return ValueListenableBuilder<bool>(
          valueListenable: _taskStore.isLoading,
          builder: (context, isLoading, _) {
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
                  _buildTaskSection(
                    context: context,
                    isLoading: isLoading,
                    tasks: tasks,
                    theme: theme,
                  ),
                ],
              ),
            );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTaskSection({
    required BuildContext context,
    required ThemeData theme,
    required bool isLoading,
    required List<TodoTask> tasks,
  }) {
    if (isLoading) {
      return _buildTaskSkeletonList(theme: theme);
    }

    if (tasks.isEmpty) {
      return _buildEmptyTaskState(theme: theme);
    }

    return _buildTaskList(theme: theme, tasks: tasks, context: context);
  }

  Widget _buildTaskList({
    required BuildContext context,
    required ThemeData theme,
    required List<TodoTask> tasks,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) {
        return Divider(
          color: theme.colorScheme.outline.withValues(alpha: 0.8),
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
          trailingAction: PopupMenuButton<String>(
            tooltip: 'Task actions',
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(
                    Icons.edit_outlined,
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                  title: Text(
                    'Edit',
                    style: theme.textTheme.bodyMedium,
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  title: Text(
                    'Delete',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                unawaited(_openEditTaskSurface(context, index, task));
              } else if (value == 'delete') {
                unawaited(
                  _taskStore.deleteTask(index: index),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildTaskSkeletonList({required ThemeData theme}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) {
        return Divider(
          color: theme.colorScheme.outline.withValues(alpha: 0.8),
          height: 1,
        );
      },
      itemBuilder: (context, index) {
        return _buildTaskSkeletonRow(theme: theme, index: index);
      },
    );
  }

  Widget _buildTaskSkeletonRow({
    required ThemeData theme,
    required int index,
  }) {
    final muted = theme.colorScheme.outline.withValues(alpha: 0.28);

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: muted.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 14,
                  width: index.isEven ? 180 : 200,
                  decoration: BoxDecoration(
                    color: muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: muted.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: muted,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildEmptyTaskState({required ThemeData theme}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(
            Icons.playlist_remove_outlined,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 56,
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a task to start tracking your work.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _openAddTaskSurface(BuildContext context) async {
    await _openTaskEditorSheet(
      context: context,
      sheetTitle: 'Add Task',
      confirmText: 'Add Task',
      initialTitle: '',
      initialMetadata: '',
      onSubmit: (title, metadata) {
        return _taskStore.addTask(
          title: title,
          metadata: metadata,
          done: false,
        );
      },
    );
  }

  Future<void> _openEditTaskSurface(
    BuildContext context,
    int index,
    TodoTask task,
  ) async {
    await _openTaskEditorSheet(
      context: context,
      sheetTitle: 'Edit Task',
      confirmText: 'Save',
      initialTitle: task.title,
      initialMetadata: task.metadata,
      onSubmit: (title, metadata) {
        return _taskStore.updateTask(
          index: index,
          title: title,
          metadata: metadata,
        );
      },
    );
  }

  Future<void> _openTaskEditorSheet({
    required BuildContext context,
    required String sheetTitle,
    required String confirmText,
    required String initialTitle,
    required String initialMetadata,
    required Future<void> Function(String title, String metadata) onSubmit,
  }) async {
    final theme = Theme.of(context);
    final titleController = TextEditingController(text: initialTitle);
    final metadataController = TextEditingController(text: initialMetadata);

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    sheetTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      hintText: 'Enter task title',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: metadataController,
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
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }

                        unawaited(
                          onSubmit(
                            title,
                            metadataController.text.trim(),
                          ),
                        );
                      },
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
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
