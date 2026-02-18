import 'package:flutter/material.dart';

import 'package:todo/ui/hooks/hook_zones.dart';

class TodoScaffold extends StatelessWidget {
  const TodoScaffold({
    super.key,
    required this.body,
    required this.onAddTask,
    this.appBarActions,
  });

  final Widget body;
  final Widget? appBarActions;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo', style: theme.textTheme.headlineMedium),
        actions: [
          KeyedSubtree(
            key: const ValueKey(TodoHookZones.appBarActions),
            child: appBarActions ?? const SizedBox.shrink(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: body,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddTask,
        tooltip: 'Add task',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
