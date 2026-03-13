// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pandaedu/main.dart';

void main() {
  testWidgets('PandaEdu app smoke test', (WidgetTester tester) async {
    // Initialize SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    // Build our app and trigger a frame
    await tester.pumpWidget(PandaEduApp(prefs: prefs));
    
    // Wait for splash screen
    await tester.pump(const Duration(seconds: 3));
    
    // Verify that app launches successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
