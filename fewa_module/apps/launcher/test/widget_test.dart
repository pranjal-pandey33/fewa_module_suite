// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that your widget behaves as expected.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';

import 'package:fewa_module_suite/main.dart';

void main() {
  testWidgets('Todo route loads in app shell', (WidgetTester tester) async {
    final routes = RouteRegistry();
    routes.register('/', (context) => const Scaffold(body: Center(child: Text('Home'))));

    await tester.pumpWidget(
      MyApp(routes: routes, initialRoute: '/'),
    );

    expect(find.text('Home'), findsOneWidget);
  });
}
