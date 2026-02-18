// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foundation/foundation.dart';
import 'package:calculator/calculator_module.dart';

void main() {
  testWidgets('Calculator screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CalculatorScreen(EventBus()),
      ),
    );

    expect(find.text('Calculator'), findsOneWidget);
    expect(find.text('Calculate (publish event)'), findsOneWidget);

    await tester.tap(find.text('Calculate (publish event)'));
    await tester.pump();
  });
}
