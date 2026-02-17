import '../foundation.dart';

typedef ModuleRegister = void Function(
  RouteRegistry routes,
  EventBus bus,
  HookRegistry hooks,
);

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
