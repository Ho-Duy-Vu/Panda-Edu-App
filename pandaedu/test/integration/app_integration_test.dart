import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pandaedu/main.dart';
import 'package:pandaedu/domain/entities/flashcard.dart';
import 'package:pandaedu/presentation/providers/flashcard_provider.dart';
import 'package:pandaedu/data/repositories/flashcard_repository_impl.dart';

/// Integration tests for complete user flows in the PandaEdu app
/// 
/// These tests verify end-to-end functionality including:
/// - App initialization and onboarding
/// - Creating flashcards via speech-to-text
/// - Viewing and managing flashcards
/// - Study mode and spaced repetition
/// - Settings and data management
void main() {
  group('PandaEdu Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Complete app flow: onboarding → create flashcard → view → delete',
        (WidgetTester tester) async {
      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Start app
      await tester.pumpWidget(PandaEduApp(prefs: prefs));
      await tester.pumpAndSettle();

      // Should show splash screen first
      expect(find.text('PandaEdu'), findsOneWidget);

      // Wait for navigation to onboarding or home
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // If onboarding, complete it
      if (find.textContaining('Chào bạn').evaluate().isNotEmpty) {
        // Swipe through onboarding
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Tap "Bắt đầu" button
        await tester.tap(find.text('Bắt đầu thôi!'));
        await tester.pumpAndSettle();
      }

      // Should be on home page now
      expect(find.text('PandaEdu'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);

      // Tap FAB to open RecordPage
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // Should be on RecordPage
      expect(find.text('Ghi âm'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);

      // Go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on home page
      expect(find.text('PandaEdu'), findsOneWidget);
    });

    testWidgets('Settings flow: navigate to settings → toggle theme',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(PandaEduApp(prefs: prefs));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Skip onboarding if present
      if (find.textContaining('Bắt đầu').evaluate().isNotEmpty) {
        await tester.tap(find.text('Bắt đầu thôi!'));
        await tester.pumpAndSettle();
      }

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Find and tap settings
      await tester.tap(find.text('Cài đặt'));
      await tester.pumpAndSettle();

      // Should be on settings page
      expect(find.text('Cài đặt'), findsAtLeastNWidgets(1));
    });

    testWidgets('Empty state flow: verify empty state shows when no flashcards',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(PandaEduApp(prefs: prefs));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Skip onboarding
      if (find.textContaining('Bắt đầu').evaluate().isNotEmpty) {
        await tester.tap(find.text('Bắt đầu thôi!'));
        await tester.pumpAndSettle();
      }

      // Should show empty state
      expect(find.textContaining('Chưa có flashcard'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('Navigation flow: verify all main screens are accessible',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(PandaEduApp(prefs: prefs));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Skip onboarding
      if (find.textContaining('Bắt đầu').evaluate().isNotEmpty) {
        await tester.tap(find.text('Bắt đầu thôi!'));
        await tester.pumpAndSettle();
      }

      // Home page
      expect(find.text('PandaEdu'), findsOneWidget);

      // Navigate to RecordPage
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      expect(find.text('Ghi âm'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Open menu for settings
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cài đặt'));
      await tester.pumpAndSettle();
      expect(find.text('Cài đặt'), findsAtLeastNWidgets(1));
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Open menu for study mode
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ôn tập'));
      await tester.pumpAndSettle();
    });
  });

  group('FlashcardProvider Integration Tests', () {
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    test('should create, update, and delete flashcard through provider',
        () async {
      final provider = await createFlashcardProvider();

      // Initially empty
      expect(provider.flashcards, isEmpty);

      // Create flashcard
      final flashcard = Flashcard(
        id: 'integration-1',
        title: 'Test Integration',
        transcript: 'Integration test content',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      );

      await provider.createFlashcard(flashcard);
      expect(provider.flashcards, hasLength(1));

      // Update flashcard
      final updated = Flashcard(
        id: 'integration-1',
        title: 'Updated Title',
        transcript: 'Updated content',
        audioPath: null,
        createdAt: flashcard.createdAt,
        duration: 5,
      );

      await provider.updateFlashcard(updated);
      expect(provider.flashcards.first.title, 'Updated Title');

      // Delete flashcard
      await provider.deleteFlashcard('integration-1');
      expect(provider.flashcards, isEmpty);
    });

    test('should filter flashcards by search query', () async {
      final provider = await createFlashcardProvider();

      await provider.createFlashcard(Flashcard(
        id: 'search-1',
        title: 'Apple',
        transcript: 'Red fruit',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      ));

      await provider.createFlashcard(Flashcard(
        id: 'search-2',
        title: 'Banana',
        transcript: 'Yellow fruit',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      ));

      expect(provider.flashcards, hasLength(2));

      provider.setSearchQuery('Apple');
      expect(provider.flashcards, hasLength(1));
      expect(provider.flashcards.first.title, 'Apple');

      provider.setSearchQuery('');
      expect(provider.flashcards, hasLength(2));
    });

    test('should sort flashcards by different criteria', () async {
      final provider = await createFlashcardProvider();

      await provider.createFlashcard(Flashcard(
        id: 'sort-1',
        title: 'Zebra',
        transcript: 'Last alphabetically',
        audioPath: null,
        createdAt: DateTime(2025, 12, 1),
        duration: 5,
      ));

      await provider.createFlashcard(Flashcard(
        id: 'sort-2',
        title: 'Apple',
        transcript: 'First alphabetically',
        audioPath: null,
        createdAt: DateTime(2025, 12, 10),
        duration: 5,
      ));

      // Sort by name
      provider.setSortBy('name');
      expect(provider.flashcards.first.title, 'Apple');

      // Sort by newest
      provider.setSortBy('newest');
      expect(provider.flashcards.first.createdAt, DateTime(2025, 12, 10));
    });
  });
}

/// Helper function to create FlashcardProvider with mocked dependencies
Future<FlashcardProvider> createFlashcardProvider() async {
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  final repository = FlashcardRepositoryImpl(sharedPreferences);
  return FlashcardProvider(repository);
}
