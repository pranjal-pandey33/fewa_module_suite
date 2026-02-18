import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class TodoTask {
  const TodoTask({
    required this.title,
    required this.metadata,
    required this.done,
    required this.createdAt,
  });

  final String title;
  final String metadata;
  final bool done;
  final DateTime createdAt;

  TodoTask copyWith({
    String? title,
    String? metadata,
    bool? done,
    DateTime? createdAt,
  }) {
    return TodoTask(
      title: title ?? this.title,
      metadata: metadata ?? this.metadata,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      title: json['title'] as String? ?? '',
      metadata: json['metadata'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'metadata': metadata,
      'done': done,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class TodoTaskStore {
  TodoTaskStore({List<TodoTask>? initialTasks, String fileName = 'todo_tasks.json'})
      : _fileName = fileName,
        tasks = ValueNotifier<List<TodoTask>>(
          List<TodoTask>.from(
            initialTasks ??
                _defaultTasks(),
          ),
        );

  final ValueNotifier<List<TodoTask>> tasks;
  final String _fileName;

  File? _file;
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;

    await _ensureFile();

    if (!await _file!.exists()) {
      await _persist();
      _loaded = true;
      return;
    }

    final raw = await _file!.readAsString();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final rawTasks = decoded['tasks'];
        if (rawTasks is List) {
          tasks.value = rawTasks
              .whereType<Map<String, dynamic>>()
              .map(TodoTask.fromJson)
              .toList();
          _loaded = true;
          return;
        }
      }
    } catch (_) {}

    await _persist();
    _loaded = true;
  }

  Future<void> addTask({
    required String title,
    required String metadata,
    required bool done,
  }) async {
    final updated = List<TodoTask>.from(tasks.value);
    updated.insert(
      0,
      TodoTask(
        title: title,
        metadata: metadata,
        done: done,
        createdAt: DateTime.now(),
      ),
    );
    tasks.value = updated;
    await _persist();
  }

  Future<void> setTaskDone({
    required int index,
    required bool done,
  }) async {
    if (index < 0 || index >= tasks.value.length) return;

    final updated = List<TodoTask>.from(tasks.value);
    updated[index] = updated[index].copyWith(done: done);
    tasks.value = updated;
    await _persist();
  }

  Future<void> _persist() async {
    await _ensureFile();

    final data = {
      'tasks': tasks.value.map((task) => task.toJson()).toList(),
    };
    await _file!.writeAsString(jsonEncode(data));
  }

  Future<void> _ensureFile() async {
    if (_file != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/$_fileName');
  }

  static List<TodoTask> _defaultTasks() {
    final now = DateTime.now();

    return [
      TodoTask(
        title: 'Finalize invoicing sequence',
        metadata: 'Due in 2 days • High priority',
        done: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      TodoTask(
        title: 'Link calculation result #182 to task',
        metadata: 'Due in 4 days • Medium priority',
        done: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TodoTask(
        title: 'Archive closed projects',
        metadata: 'No due date • Low priority',
        done: false,
        createdAt: now,
      ),
    ];
  }
}
