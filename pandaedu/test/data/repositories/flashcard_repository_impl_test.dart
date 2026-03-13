import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pandaedu/domain/entities/flashcard.dart';
import 'package:pandaedu/data/models/flashcard_model.dart';
import 'package:pandaedu/data/repositories/flashcard_repository_impl.dart';

void main() {
  group('FlashcardRepositoryImpl Tests', () {
    late SharedPreferences sharedPreferences;
    late FlashcardRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      repository = FlashcardRepositoryImpl(sharedPreferences);
    });

    test('should return empty list when no flashcards exist', () async {
      final flashcards = await repository.getAllFlashcards();
      expect(flashcards, isEmpty);
    });

    test('should create and retrieve a flashcard', () async {
      final flashcard = Flashcard(
        id: 'test-1',
        title: 'Test Card',
        transcript: 'Test transcript',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      );

      await repository.createFlashcard(flashcard);
      final flashcards = await repository.getAllFlashcards();

      expect(flashcards, hasLength(1));
      expect(flashcards.first.id, 'test-1');
      expect(flashcards.first.title, 'Test Card');
      expect(flashcards.first.transcript, 'Test transcript');
    });

    test('should update an existing flashcard', () async {
      final flashcard = Flashcard(
        id: 'test-2',
        title: 'Original Title',
        transcript: 'Original transcript',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      );

      await repository.createFlashcard(flashcard);

      final updatedFlashcard = Flashcard(
        id: 'test-2',
        title: 'Updated Title',
        transcript: 'Updated transcript',
        audioPath: null,
        createdAt: flashcard.createdAt,
        duration: 5,
      );

      await repository.updateFlashcard(updatedFlashcard);
      final flashcards = await repository.getAllFlashcards();

      expect(flashcards, hasLength(1));
      expect(flashcards.first.title, 'Updated Title');
      expect(flashcards.first.transcript, 'Updated transcript');
    });

    test('should delete a flashcard', () async {
      final flashcard = Flashcard(
        id: 'test-3',
        title: 'To Delete',
        transcript: 'Will be deleted',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      );

      await repository.createFlashcard(flashcard);
      expect(await repository.getAllFlashcards(), hasLength(1));

      await repository.deleteFlashcard('test-3');
      expect(await repository.getAllFlashcards(), isEmpty);
    });

    test('should get flashcard by id', () async {
      final flashcard = Flashcard(
        id: 'test-4',
        title: 'Find Me',
        transcript: 'Found it',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      );

      await repository.createFlashcard(flashcard);
      final found = await repository.getFlashcardById('test-4');

      expect(found, isNotNull);
      expect(found!.id, 'test-4');
      expect(found.title, 'Find Me');
    });

    test('should return null for non-existent flashcard', () async {
      final found = await repository.getFlashcardById('non-existent');
      expect(found, isNull);
    });

    test('should get due flashcards', () async {
      final dueFlashcard = Flashcard(
        id: 'due-1',
        title: 'Due Card',
        transcript: 'Due for review',
        audioPath: null,
        createdAt: DateTime.now(),
        nextReviewAt: DateTime.now().subtract(const Duration(days: 1)),
        duration: 5,
      );

      final notDueFlashcard = Flashcard(
        id: 'not-due-1',
        title: 'Not Due Card',
        transcript: 'Not due yet',
        audioPath: null,
        createdAt: DateTime.now(),
        nextReviewAt: DateTime.now().add(const Duration(days: 1)),
        duration: 5,
      );

      await repository.createFlashcard(dueFlashcard);
      await repository.createFlashcard(notDueFlashcard);

      final dueCards = await repository.getDueFlashcards();
      expect(dueCards, hasLength(1));
      expect(dueCards.first.id, 'due-1');
    });

    test('should search flashcards by title', () async {
      await repository.createFlashcard(Flashcard(
        id: 'search-1',
        title: 'Apple Fruit',
        transcript: 'Red and delicious',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      ));

      await repository.createFlashcard(Flashcard(
        id: 'search-2',
        title: 'Banana',
        transcript: 'Yellow fruit',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      ));

      final results = await repository.searchFlashcards('Apple');
      expect(results, hasLength(1));
      expect(results.first.title, 'Apple Fruit');
    });

    test('should search flashcards by transcript', () async {
      await repository.createFlashcard(Flashcard(
        id: 'search-3',
        title: 'Test',
        transcript: 'Contains keyword special',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      ));

      await repository.createFlashcard(Flashcard(
        id: 'search-4',
        title: 'Another',
        transcript: 'No keyword here',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      ));

      final results = await repository.searchFlashcards('special');
      expect(results, hasLength(1));
      expect(results.first.transcript, contains('special'));
    });

    test('should handle creating multiple flashcards without type error', () async {
      final flashcard1 = Flashcard(
        id: 'multi-1',
        title: 'First',
        transcript: 'First transcript',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      );

      final flashcard2 = Flashcard(
        id: 'multi-2',
        title: 'Second',
        transcript: 'Second transcript',
        audioPath: null,
        createdAt: DateTime.now(),
        duration: 5,
      );

      await repository.createFlashcard(flashcard1);
      await repository.createFlashcard(flashcard2);

      final flashcards = await repository.getAllFlashcards();
      expect(flashcards, hasLength(2));
      expect(flashcards[0].id, 'multi-1');
      expect(flashcards[1].id, 'multi-2');
    });

    test('should serialize and deserialize flashcard correctly', () async {
      final original = Flashcard(
        id: 'serialize-1',
        title: 'Test Title',
        transcript: 'Test Transcript',
        audioPath: '/path/to/audio.m4a',
        createdAt: DateTime(2025, 12, 10, 10, 30),
        nextReviewAt: DateTime(2025, 12, 15, 10, 30),
        repeatLevel: 3,
        favorite: true,
        duration: 10,
      );

      await repository.createFlashcard(original);
      final retrieved = await repository.getFlashcardById('serialize-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, original.id);
      expect(retrieved.title, original.title);
      expect(retrieved.transcript, original.transcript);
      expect(retrieved.audioPath, original.audioPath);
      expect(retrieved.repeatLevel, original.repeatLevel);
      expect(retrieved.favorite, original.favorite);
      expect(retrieved.duration, original.duration);
    });
  });
}
