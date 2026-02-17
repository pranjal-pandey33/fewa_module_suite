import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'package:todo/todo_module.dart';

final RouteRegistry _routes = RouteRegistry();
final EventBus _eventBus = EventBus();
final HookRegistry _hooks = HookRegistry();

void main() {
  TodoModule.register(_routes, _eventBus, _hooks);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Launcher',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: TodoModule.route,
      routes: _routes.getRoutes(),
    );
  }
}
