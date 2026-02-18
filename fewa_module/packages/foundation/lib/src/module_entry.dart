import 'event_bus.dart';
import 'hook_registry.dart';
import 'route_registry.dart';

typedef ModuleRegister = void Function(
  RouteRegistry routes,
  EventBus bus,
  HookRegistry hooks,
);

class ModuleEntry {
  final String name;
  final ModuleRegister register;

  const ModuleEntry({required this.name, required this.register});
}
