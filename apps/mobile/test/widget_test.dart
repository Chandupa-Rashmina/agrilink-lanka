import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('basic Flutter test environment works', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('AgriLink Lanka'))),
    );

    expect(find.text('AgriLink Lanka'), findsOneWidget);
  });
}
