import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

import 'src/data/todo_projection_store.dart';

class TodoModule {
  static const route = '/todo';
  static final TodoProjectionStore projections = TodoProjectionStore();

  @override
  Future<void> start(ModuleContext ctx) async {
    await projections.init();
    ctx.log("Projection store initialized.");
  }

  static void register(RouteRegistry routes, EventBus bus, HookRegistry hooks) {
    routes.register(route, (_) => const TodoScreen());

    // Just to prove wiring:
    hooks.register('home.actions', () {
      debugPrint('TodoModule contributed an action!');
    });

    bus.subscribe<CalculationCompleted>((event) async {
      await projections.init();
      await projections.increment();
      debugPrint("Todo received result: ${event.result} | total=${TodoModule.projections.calcCount.value}");
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text('Todo')),
      body: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: TodoModule.projections.calcCount,
          builder: (_, value, __) => Text("Calc events received: $value"),
        ),
      ),
    );
  }
}
