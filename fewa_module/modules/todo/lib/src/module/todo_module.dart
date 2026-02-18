import 'dart:async';

import 'package:foundation/foundation.dart';

import 'package:todo/ui/screens/todo_home.dart';

import '../data/todo_projection_store.dart';
import '../data/todo_task_store.dart';

class TodoModule {
  static const route = '/todo';
  static final TodoProjectionStore projections = TodoProjectionStore();
  static final TodoTaskStore tasks = TodoTaskStore();

  static void register(RouteRegistry routes, EventBus bus, HookRegistry hooks) {
    routes.register(
      route,
      (_) => TodoHome(
        calculationEvents: projections.calcCount,
        taskStore: tasks,
        hooks: hooks,
      ),
    );
    unawaited(TodoModule.projections.init());
    unawaited(TodoModule.tasks.init());

    bus.subscribe<CalculationCompleted>((_) {
      unawaited(TodoModule.projections.increment());
    });
  }
}
