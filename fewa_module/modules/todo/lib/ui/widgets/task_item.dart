import 'package:flutter/material.dart';

class TaskItem extends StatelessWidget {
  const TaskItem({
    super.key,
    required this.title,
    required this.metadata,
    required this.completed,
    this.onChanged,
    this.trailingAction,
  });

  final String title;
  final String metadata;
  final bool completed;
  final ValueChanged<bool?>? onChanged;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = completed
        ? theme.colorScheme.onSurface.withOpacity(0.6)
        : theme.colorScheme.onSurface;

      return Container(
      constraints: const BoxConstraints(minHeight: 56),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Checkbox(
            value: completed,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
            checkColor: theme.colorScheme.onPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      decoration: completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationThickness: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    metadata,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            height: 24,
            child: KeyedSubtree(
              key: const ValueKey('todo.task.item.trailing'),
              child: trailingAction ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
