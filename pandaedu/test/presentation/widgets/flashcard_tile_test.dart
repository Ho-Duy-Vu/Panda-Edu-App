import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandaedu/domain/entities/flashcard.dart';
import 'package:pandaedu/presentation/widgets/flashcard_tile.dart';
import 'package:pandaedu/core/theme.dart';

void main() {
  group('FlashcardTile Widget Tests', () {
    late Flashcard testFlashcard;

    setUp(() {
      testFlashcard = Flashcard(
        id: 'test-id-1',
        title: 'Test Flashcard',
        transcript: 'This is a test transcript for the flashcard widget',
        audioPath: null,
        createdAt: DateTime(2025, 12, 10),
        duration: 5,
      );
    });

    testWidgets('should display flashcard title and transcript', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FlashcardTile(
              flashcard: testFlashcard,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Flashcard'), findsOneWidget);
      expect(find.text('This is a test transcript for the flashcard widget'), findsOneWidget);
    });

    testWidgets('should show panda placeholder image', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FlashcardTile(
              flashcard: testFlashcard,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should call onTap when tile is tapped', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FlashcardTile(
              flashcard: testFlashcard,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FlashcardTile));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('should show play icon when audioPath is present', (WidgetTester tester) async {
      final flashcardWithAudio = Flashcard(
        id: 'test-id-2',
        title: 'Audio Flashcard',
        transcript: 'This has audio',
        audioPath: '/path/to/audio.m4a',
        createdAt: DateTime.now(),
        duration: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FlashcardTile(
              flashcard: flashcardWithAudio,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('should NOT show play icon when audioPath is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FlashcardTile(
              flashcard: testFlashcard,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_circle_outline), findsNothing);
    });

    testWidgets('should format date correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FlashcardTile(
              flashcard: testFlashcard,
              onTap: () {},
            ),
          ),
        ),
      );

      // Check for date text (format may vary based on locale)
      expect(find.textContaining('2025'), findsOneWidget);
    });
  });
}
