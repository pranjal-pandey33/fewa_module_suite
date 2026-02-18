import 'dart:async';
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
            initialTasks ?? const [],
          ),
        ),
        isLoading = ValueNotifier<bool>(true);

  final ValueNotifier<List<TodoTask>> tasks;
  final ValueNotifier<bool> isLoading;
  final String _fileName;

  File? _file;
  bool _loaded = false;
  Future<void>? _initFuture;

  Future<void> init() async {
    _logEvent(
      action: 'todo.task_store.init.start',
      details: {
        'fileName': _fileName,
        'hasCache': _loaded,
      },
    );

    if (_loaded) return;
    if (_initFuture != null) {
      await _initFuture;
      return;
    }

    _initFuture = _initialize();
    try {
      await _initFuture;
      _logEvent(
        action: 'todo.task_store.init.complete',
        details: {
          'fileName': _fileName,
          'taskCount': tasks.value.length,
          'isLoading': isLoading.value,
        },
      );
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _initialize() async {
    isLoading.value = true;

    try {
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
    } finally {
      isLoading.value = false;
      _loaded = true;
    }
  }

  Future<void> addTask({
    required String title,
    required String metadata,
    required bool done,
  }) async {
    _logEvent(
      action: 'todo.task_store.add_task',
      details: {
        'titleLength': title.trim().length,
        'metadataLength': metadata.length,
        'done': done,
        'taskCountBefore': tasks.value.length,
      },
    );

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
    _logEvent(
      action: 'todo.task_store.tasks_mutated',
      details: {
        'operation': 'add',
        'taskCountAfter': updated.length,
      },
    );
    await _persist();
  }

  Future<void> setTaskDone({
    required int index,
    required bool done,
  }) async {
    if (index < 0 || index >= tasks.value.length) return;

    final updated = List<TodoTask>.from(tasks.value);
    final previous = updated[index];
    updated[index] = updated[index].copyWith(done: done);
    _logEvent(
      action: 'todo.task_store.set_task_done',
      details: {
        'index': index,
        'previousDone': previous.done,
        'done': done,
        'taskCount': updated.length,
      },
    );
    tasks.value = updated;
    _logEvent(
      action: 'todo.task_store.tasks_mutated',
      details: {
        'operation': 'toggle_done',
        'taskCount': updated.length,
      },
    );
    await _persist();
  }

  Future<void> updateTask({
    required int index,
    required String title,
    required String metadata,
    bool? done,
  }) async {
    if (index < 0 || index >= tasks.value.length) return;

    final updated = List<TodoTask>.from(tasks.value);
    final current = updated[index];
    updated[index] = current.copyWith(
      title: title,
      metadata: metadata,
      done: done ?? current.done,
    );
    _logEvent(
      action: 'todo.task_store.update_task',
      details: {
        'index': index,
        'titleLength': title.trim().length,
        'metadataLength': metadata.length,
        'done': done ?? current.done,
        'taskCount': updated.length,
      },
    );
    tasks.value = updated;
    _logEvent(
      action: 'todo.task_store.tasks_mutated',
      details: {
        'operation': 'update',
        'taskCount': updated.length,
      },
    );
    await _persist();
  }

  Future<void> deleteTask({required int index}) async {
    if (index < 0 || index >= tasks.value.length) return;

    final updated = List<TodoTask>.from(tasks.value);
    updated.removeAt(index);
    _logEvent(
      action: 'todo.task_store.delete_task',
      details: {
        'index': index,
        'taskCountBefore': tasks.value.length,
        'taskCountAfter': updated.length,
      },
    );
    tasks.value = updated;
    _logEvent(
      action: 'todo.task_store.tasks_mutated',
      details: {
        'operation': 'delete',
        'taskCount': updated.length,
      },
    );
    await _persist();
  }

  Future<void> _persist() async {
    _logEvent(
      action: 'todo.task_store.persist',
      details: {
        'fileName': _fileName,
        'taskCount': tasks.value.length,
      },
    );
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

  void dispose() {
    tasks.dispose();
    isLoading.dispose();
  }

  void _logEvent({
    required String action,
    required Map<String, Object?> details,
  }) {
    if (!kDebugMode) return;
    final payload = <String, Object?>{
      'event': 'todo_task_store',
      'action': action,
      'ts': DateTime.now().toIso8601String(),
      'details': details,
    };

    debugPrint(jsonEncode(payload));
  }
}
