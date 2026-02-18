import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'src/data/todo_projection_store.dart';
import 'ui/screens/todo_home.dart';

class TodoModule {
  static const route = '/todo';
  static final TodoProjectionStore projections = TodoProjectionStore();

  static void register(RouteRegistry routes, EventBus bus, HookRegistry hooks) {
    routes.register(route, (_) => const TodoHome());
    unawaited(TodoModule.projections.init());

    hooks.register('home.actions', () {
      debugPrint('TodoModule contributed an action!');
    });

    bus.subscribe<CalculationCompleted>((_) {
      unawaited(TodoModule.projections.increment());
    });
  }
}
