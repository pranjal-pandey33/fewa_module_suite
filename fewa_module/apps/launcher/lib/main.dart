import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:foundation/foundation.dart';
import 'package:todo/todo_module.dart';
import 'package:calculator/calculator_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read requested modules from --dart-define=MODULES=todo,calculator
  const modulesRaw = String.fromEnvironment('MODULES', defaultValue: 'todo,calculator');
  final requested = modulesRaw
      .split(',')
      .map((s) => s.trim().toLowerCase())
      .where((s) => s.isNotEmpty)
      .toList();

  if (requested.isEmpty) {
    throw StateError(
      'No modules selected. Run with --dart-define=MODULES=todo[,calculator]',
    );
  }

  // 1) Load manifests (from package assets)
  final manifests = <String, ModuleManifest>{};

  Future<ModuleManifest> loadManifest(String packageName) async {
    final raw = await rootBundle.loadString('packages/$packageName/module.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;

    return ModuleManifest(
      name: json['name'] as String,
      version: json['version'] as String,
      mainRoute: json['main_route'] as String,
      dependencies: (json['dependencies'] as List).cast<String>(),
    );
  }

  // We only have these two modules for now.
  // Later we’ll discover modules automatically.
  for (final pkg in ['todo', 'calculator']) {
    final m = await loadManifest(pkg);
    manifests[m.name] = m;
  }

  // 2) Resolve dependencies + load order
  final resolver = DependencyResolver();
  final loadOrder = resolver.resolve(requested: requested, all: manifests);

  // 3) Map module name -> register function
  ModuleRegister registerFor(String name) {
    switch (name) {
      case 'todo':
        return TodoModule.register;
      case 'calculator':
        return CalculatorModule.register;
      default:
        throw StateError('No register() mapping for module: $name');
    }
  }

  // 4) Boot kernel + load modules
  final eventBus = EventBus();
  final hooks = HookRegistry();
  final routes = RouteRegistry();

  final loader = ModuleLoader(eventBus: eventBus, hooks: hooks, routes: routes);

  loader.load(loadOrder.map(registerFor).toList());

  final requiredRoutes = <String>[];
  for (final moduleName in loadOrder) {
    final moduleMainRoute = manifests[moduleName]?.mainRoute;
    if (moduleMainRoute != null && !routes.hasRoute(moduleMainRoute)) {
      requiredRoutes.add(moduleMainRoute);
    }
  }

  if (requiredRoutes.isNotEmpty) {
    throw StateError(
      'Route registration incomplete. Expected main routes missing: $requiredRoutes. '
      'Registered: ${routes.registeredPaths}',
    );
  }

  // Optional debug signal for compose correctness.
  debugPrint('MODULES=${requested.join(",")}');
  debugPrint('Load order=${loadOrder.join(",")}');
  debugPrint('Registered routes=${routes.registeredPaths.join(", ")}');

  // Start screen: first requested module’s main_route (fallback to first loaded)
  final initial = manifests[requested.first]?.mainRoute ??
      manifests[loadOrder.first]!.mainRoute;

  runApp(MyApp(routes: routes, initialRoute: initial));
}

class MyApp extends StatelessWidget {
  final RouteRegistry routes;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.routes,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      routes: routes.getRoutes(),
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Text('Unknown route: ${settings.name}'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                'No registered route for ${settings.name}.\n'
                'Registered routes: ${routes.registeredPaths.join(', ')}',
              ),
            ),
          ),
        );
      },
    );
  }
}
