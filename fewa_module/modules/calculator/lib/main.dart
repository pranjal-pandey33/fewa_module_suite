import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

import 'calculator_module.dart';

void main() {
  runApp(const CalculatorModuleApp());
}

class CalculatorModuleApp extends StatelessWidget {
  const CalculatorModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalculatorScreen(EventBus()),
    );
  }
}
