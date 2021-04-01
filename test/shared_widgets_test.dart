import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_hobby_app/shared/loading.dart';

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  group('Test Shared Screens', () {
    testWidgets('Loading:', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: Loading()));

      await tester.pump();
    });
  });
}
