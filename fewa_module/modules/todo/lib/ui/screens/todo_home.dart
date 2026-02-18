import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:foundation/foundation.dart';
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
    HookRegistry? hooks,
  }) : _taskStore = taskStore,
       _hooks = hooks;

  final ValueListenable<int> calculationEvents;
  final TodoTaskStore? _taskStore;
  final HookRegistry? _hooks;

  @override
  State<TodoHome> createState() => _TodoHomeState();
}

enum _TaskFilter { all, active, completed }

class _TodoHomeState extends State<TodoHome> {
  late final TodoTaskStore _taskStore = widget._taskStore ?? TodoTaskStore();
  _TaskFilter _selectedFilter = _TaskFilter.all;

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
              appBarActions: _buildAppBarHookActions(),
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
                  _buildDashboardHookCards(),
                  const SizedBox(height: 16),
                  Text(
                    'Task List',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildTaskFilterBar(theme: theme),
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

  Widget _buildAppBarHookActions() {
    final contributions = _hookWidgets(TodoHookZones.appBarActions);

    if (contributions.isEmpty) {
      return const SizedBox.shrink();
    }

    final direct = contributions.take(3).toList();
    final overflow = contributions.skip(3).toList();

    return KeyedSubtree(
      key: const ValueKey(TodoHookZones.appBarActions),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...direct.map(
            (child) => _normalizeAppBarAction(child: child),
          ),
          if (overflow.isNotEmpty)
            _buildHookOverflowButton(
              triggerIcon: Icons.more_horiz,
              tooltip: 'More actions',
              overflowItems: overflow,
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardHookCards() {
    final contributions = _hookWidgets(TodoHookZones.dashboardCards);
    if (contributions.isEmpty) {
      return const SizedBox.shrink();
    }

    return KeyedSubtree(
      key: const ValueKey(TodoHookZones.dashboardCards),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: contributions,
      ),
    );
  }

  List<Widget> _hookWidgets(String hookName) {
    final registered = widget._hooks?.contributions(hookName) ?? const [];
    final widgets = <Widget>[];

    for (final contribution in registered) {
      try {
        final value = contribution();
        if (value is Widget) {
          widgets.add(value);
        }
      } catch (_) {
        // Ignore malformed hooks to keep list rendering stable.
      }
    }

    return widgets;
  }

  Widget _buildHookOverflowButton({
    required IconData triggerIcon,
    required String tooltip,
    required List<Widget> overflowItems,
  }) {
    return PopupMenuButton<int>(
      tooltip: tooltip,
      icon: Icon(triggerIcon),
      itemBuilder: (context) => overflowItems
          .asMap()
          .entries
          .map(
            (entry) => PopupMenuItem<int>(
              value: entry.key,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SizedBox(
                  width: 240,
                  child: overflowItems[entry.key],
                ),
              ),
            ),
          )
          .toList(),
      onSelected: (_) {},
    );
  }

  Widget _normalizeAppBarAction({required Widget child}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(child: child),
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

    final filteredTasks = _filteredTaskEntries(tasks);
    if (filteredTasks.isEmpty) {
      return _buildEmptyTaskState(theme: theme);
    }

    return _buildTaskList(
      theme: theme,
      tasks: filteredTasks,
      context: context,
    );
  }

  Widget _buildTaskList({
    required BuildContext context,
    required ThemeData theme,
    required List<MapEntry<int, TodoTask>> tasks,
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
        final taskEntry = tasks[index];
        final taskIndex = taskEntry.key;
        final task = taskEntry.value;
        return TaskItem(
          title: task.title,
          metadata: task.metadata,
          completed: task.done,
          onChanged: (value) {
            if (value == null) return;
            unawaited(
              _taskStore.setTaskDone(index: taskIndex, done: value),
            );
          },
          trailingAction: PopupMenuButton<String>(
            key: ValueKey('task-trailing-menu-$taskIndex'),
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
              ..._taskTrailingHookEntries(theme: theme),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                unawaited(_openEditTaskSurface(context, taskIndex, task));
              } else if (value == 'delete') {
                unawaited(
                  _taskStore.deleteTask(index: taskIndex),
                );
              }
            },
          ),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _taskTrailingHookEntries({
    required ThemeData theme,
  }) {
    final contributions = _hookWidgets(TodoHookZones.taskItemTrailing);
    if (contributions.isEmpty) {
      return const [];
    }

    return contributions
        .asMap()
        .entries
        .map(
          (entry) => PopupMenuItem<String>(
            value: 'hook-${entry.key}',
            child: DefaultTextStyle(
              style: theme.textTheme.bodyMedium!,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: entry.value,
              ),
            ),
          ),
        )
        .toList();
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
    final label = switch (_selectedFilter) {
      _TaskFilter.all => 'No tasks yet',
      _TaskFilter.active => 'No active tasks yet',
      _TaskFilter.completed => 'No completed tasks yet',
    };

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
            label,
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

  Widget _buildTaskFilterBar({required ThemeData theme}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _TaskFilter.values.map((filter) {
        final isSelected = _selectedFilter == filter;
        return ChoiceChip(
          label: Text(_filterLabel(filter)),
          selected: isSelected,
          onSelected: (selected) {
            if (!selected) return;
            setState(() {
              _selectedFilter = filter;
            });
          },
          labelStyle: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: theme.colorScheme.secondaryContainer,
          shape: const StadiumBorder(),
        );
      }).toList(),
    );
  }

  String _filterLabel(_TaskFilter filter) {
    return switch (filter) {
      _TaskFilter.all => 'All',
      _TaskFilter.active => 'Active',
      _TaskFilter.completed => 'Completed',
    };
  }

  List<MapEntry<int, TodoTask>> _filteredTaskEntries(List<TodoTask> tasks) {
    return switch (_selectedFilter) {
      _TaskFilter.all => tasks.asMap().entries.toList(),
      _TaskFilter.active => tasks.asMap().entries
          .where((entry) => !entry.value.done)
          .toList(),
      _TaskFilter.completed => tasks.asMap().entries
          .where((entry) => entry.value.done)
          .toList(),
    };
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
