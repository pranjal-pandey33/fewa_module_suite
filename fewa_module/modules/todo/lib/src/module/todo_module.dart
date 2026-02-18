import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

import 'package:todo/ui/screens/todo_home.dart';
import 'package:todo/ui/hooks/hook_zones.dart';

import '../data/todo_projection_store.dart';

class TodoModule {
  static const route = '/todo';
  static final TodoProjectionStore projections = TodoProjectionStore();

  static void register(RouteRegistry routes, EventBus bus, HookRegistry hooks) {
    routes.register(
      route,
      (_) => TodoHome(
        calculationEvents: projections.calcCount,
      ),
    );
    unawaited(TodoModule.projections.init());

    hooks.register(TodoHookZones.appBarActions, () {
      debugPrint('TodoModule contributed an action!');
    });

    bus.subscribe<CalculationCompleted>((_) {
      unawaited(TodoModule.projections.increment());
    });
  }
}
