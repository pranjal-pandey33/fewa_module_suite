import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class TodoModule {
  static const route = '/todo';

  static void register(RouteRegistry routes, EventBus bus, HookRegistry hooks) {
    routes.register(route, (_) => const TodoScreen());

    // Just to prove wiring:
    hooks.register('home.actions', () {
      debugPrint('TodoModule contributed an action!');
    });

    bus.subscribe<String>((msg) {
      debugPrint('TodoModule received message: $msg');
    });
  }
}

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text('Todo')),
      body: Center(child: Text('Todo Module Screen')),
    );
  }
}
