import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'src/data/todo_projection_store.dart';

class TodoModule {
  static const route = '/todo';
static int _calcCount = 0;
static int get calcCount => _calcCount;
static final TodoProjectionStore projections = TodoProjectionStore();


  static void register(RouteRegistry routes, EventBus bus, HookRegistry hooks) {
    routes.register(route, (_) => const TodoScreen());

    // Just to prove wiring:
    hooks.register('home.actions', () {
      debugPrint('TodoModule contributed an action!');
    });

bus.subscribe<CalculationCompleted>((event) async {
  await projections.increment();
});


  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    
    return  Scaffold(
      appBar: AppBar(title: Text('Todo')),
body: Center(
  child: Text("Calc events received: ${TodoModule.calcCount}"),
),
    );
  }
}
