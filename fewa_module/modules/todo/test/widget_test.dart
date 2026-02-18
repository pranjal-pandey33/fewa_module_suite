// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo/ui/screens/todo_home.dart';

void main() {
  testWidgets('Todo home renders projection count', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TodoHome(calculationEvents: ValueNotifier<int>(3)),
      ),
    );

    expect(find.text('Todo'), findsOneWidget);
    expect(find.text('Calculation Events Today'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    expect(find.text('Finalize invoicing sequence'), findsOneWidget);
  });
}
