import 'dart:convert';
import 'dart:io';

const _inputPath = 'apps/launcher/assets/modules_index.json';
const _outputPath = 'apps/launcher/lib/generated/module_registry.g.dart';

Future<void> main() async {
  final inputFile = File(_inputPath);
  if (!await inputFile.exists()) {
    throw StateError('Missing modules index at $_inputPath');
  }

  final data = jsonDecode(await inputFile.readAsString()) as Map<String, dynamic>;
  final modules = (data['modules'] as List<dynamic>?) ?? const [];

  final lines = <String>[
    '// GENERATED CODE - DO NOT MODIFY BY HAND',
    '// Run: dart tools/generate_module_registry.dart',
    '',
    'import \'package:foundation/foundation.dart\';',
    '',
  ];

  for (final module in modules.cast<Map<String, dynamic>>()) {
    final packageName = module['package'] as String;

    lines.add('import \'package:$packageName/module_entry.dart\';');
  }

  lines.add('');
  lines.add('final Map<String, ModuleEntry> moduleRegistry = {');

  for (final module in modules.cast<Map<String, dynamic>>()) {
    final name = module['name'] as String;
    final entryConst = module['entryConst'] as String;
    lines.add('  \'$name\': $entryConst,');
  }
  lines.add('};');

  final outputFile = File(_outputPath);
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString('${lines.join('\n')}\n');
}
