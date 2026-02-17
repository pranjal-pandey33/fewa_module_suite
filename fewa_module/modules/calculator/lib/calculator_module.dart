import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class CalculatorModule {
  static const route = '/calculator';

  static void register(RouteRegistry routes, EventBus bus, HookRegistry hooks) {
    routes.register(route, (_) => const CalculatorScreen());

    // Prove cross-module comms later:
    hooks.register('home.actions', () {
      debugPrint('CalculatorModule contributed an action!');
    });
  }
}

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // We'll switch this to a typed event soon.
            debugPrint('Calculator: clicked');
          },
          child: const Text('Click me'),
        ),
      ),
    );
  }
}
