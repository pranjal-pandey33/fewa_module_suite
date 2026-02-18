import 'module_entry.dart';
import 'event_bus.dart';
import 'hook_registry.dart';
import 'route_registry.dart';

class ModuleLoader {
  final EventBus eventBus;
  final HookRegistry hooks;
  final RouteRegistry routes;

  ModuleLoader({
    required this.eventBus,
    required this.hooks,
    required this.routes,
  });

  void load(List<ModuleRegister> modules) {
    for (final register in modules) {
      register(routes, eventBus, hooks);
    }
  }
}
