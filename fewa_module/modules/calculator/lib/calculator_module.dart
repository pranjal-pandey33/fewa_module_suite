import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class CalculatorModule {
  static const route = '/calculator';

  static void register(RouteRegistry routes, EventBus bus, HookRegistry hooks) {
    routes.register(route, (_) => CalculatorScreen(bus));

    // Prove cross-module comms later:
    hooks.register('home.actions', () {
      debugPrint('CalculatorModule contributed an action!');
    });
  }
}

class CalculatorScreen extends StatelessWidget {
  final EventBus bus;

  const CalculatorScreen(this.bus, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calculator',
          style: theme.textTheme.headlineMedium,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                final result = 2 + 2;
                bus.publish(CalculationCompleted(result));
              },
              child: const Text('Calculate (publish event)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/todo'),
              child: const Text('Go to Todo'),
            ),
          ],
        ),
      ),

    );
  }
}
