import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

final EventBus _eventBus = EventBus();

class TestEvent {
  final String message;

  const TestEvent(this.message);
}

void main() {
  _eventBus.subscribe<TestEvent>((event) {
    print('Received TestEvent: ${event.message}');
  });
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
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    _eventBus.publish(TestEvent('Home widget initialized'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EventBus Demo')),
      body: const Center(
        child: Text('Open the console to see TestEvent output.'),
      ),
    );
  }
}
