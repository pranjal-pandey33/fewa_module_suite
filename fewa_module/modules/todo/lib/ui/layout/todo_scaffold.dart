import 'package:flutter/material.dart';

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
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width >= 768 ? 32.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo', style: theme.textTheme.titleLarge),
        actions: [
          KeyedSubtree(
            key: const ValueKey('todo.appbar.actions'),
            child: appBarActions ?? const SizedBox.shrink(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
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
