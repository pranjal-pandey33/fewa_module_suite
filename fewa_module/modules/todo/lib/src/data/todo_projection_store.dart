import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class TodoProjectionStore {
  final ValueNotifier<int> calcCount = ValueNotifier<int>(0);

  File? _file;
  bool _loaded = false;

  Future<void> init() async {
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

    _loaded = true;
  }

  Future<void> increment() async {
    calcCount.value += 1;
    await _persist();
  }

  Future<void> _persist() async {
    if (_file == null) return;
    final data = {'calcCount': calcCount.value};
    await _file!.writeAsString(jsonEncode(data));
  }
}
