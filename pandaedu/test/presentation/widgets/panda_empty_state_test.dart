import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandaedu/presentation/widgets/panda_empty_state.dart';
import 'package:pandaedu/core/theme.dart';

void main() {
  group('PandaEmptyState Widget Tests', () {
    testWidgets('should display message and panda image', (WidgetTester tester) async {
      const testMessage = 'No flashcards yet!';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: PandaEmptyState(message: testMessage),
          ),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display message with custom image', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PandaEmptyState(
              message: 'Custom message',
              imagePath: 'assets/images/panda_sad.png',
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsWidgets);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should be centered in parent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PandaEmptyState(message: 'Test'),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });
  });
}
