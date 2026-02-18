import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class TodoProjectionStore {
  final ValueNotifier<int> calcCount = ValueNotifier<int>(0);

  File? _file;
  bool _loaded = false;

  Future<void> init() async {
    _logEvent(
      action: 'todo.projection_store.init.start',
      details: {'fileName': 'todo_projection.json'},
    );

    if (_loaded) return;

    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/todo_projection.json');

    if (await _file!.exists()) {
      final raw = await _file!.readAsString();
      final data = jsonDecode(raw);
      calcCount.value = (data['calcCount'] as num?)?.toInt() ?? 0;
    } else {
      calcCount.value = 0;
    }
    _logEvent(
      action: 'todo.projection_store.init.complete',
      details: {
        'fileName': 'todo_projection.json',
        'calcCount': calcCount.value,
      },
    );

    _loaded = true;
  }

  Future<void> increment() async {
    final previous = calcCount.value;
    calcCount.value += 1;
    _logEvent(
      action: 'todo.projection_store.increment',
      details: {
        'previous': previous,
        'current': calcCount.value,
      },
    );
    await _persist();
  }

  Future<void> _persist() async {
    _logEvent(
      action: 'todo.projection_store.persist',
      details: {
        'calcCount': calcCount.value,
      },
    );
    if (_file == null) return;
    final data = {'calcCount': calcCount.value};
    await _file!.writeAsString(jsonEncode(data));
  }

  void _logEvent({
    required String action,
    required Map<String, Object?> details,
  }) {
    if (!kDebugMode) return;
    final payload = <String, Object?>{
      'event': 'todo_projection',
      'action': action,
      'ts': DateTime.now().toIso8601String(),
      'details': details,
    };
    debugPrint(jsonEncode(payload));
  }
}
