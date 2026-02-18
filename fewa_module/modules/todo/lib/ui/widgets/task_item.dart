import 'package:flutter/material.dart';

class TaskItem extends StatefulWidget {
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
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _isCompleted = false;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.completed;
  }

  @override
  void didUpdateWidget(covariant TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completed != widget.completed) {
      setState(() {
        _isCompleted = widget.completed;
      });
    }
  }

  Future<void> _handleChanged(bool? value) async {
    if (value == null) return;

    setState(() {
      _isCompleted = value;
      _scale = 0.97;
    });

    widget.onChanged?.call(value);

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = _isCompleted
        ? theme.colorScheme.onSurface.withOpacity(0.6)
        : theme.colorScheme.onSurface;

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Checkbox(
              value: _isCompleted,
              onChanged: _handleChanged,
              activeColor: theme.colorScheme.primary,
              checkColor: theme.colorScheme.onPrimary,
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
                  Text(
                    widget.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      decoration: _isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationThickness: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.metadata,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            child: KeyedSubtree(
              key: const ValueKey('todo.task.item.trailing'),
              child: widget.trailingAction ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
