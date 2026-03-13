import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pandaedu/domain/entities/flashcard.dart';
import 'package:pandaedu/data/repositories/flashcard_repository_impl.dart';
import 'package:pandaedu/domain/usecases/create_flashcard.dart';
import 'package:pandaedu/domain/usecases/get_all_flashcards.dart';
import 'package:pandaedu/domain/usecases/update_flashcard.dart';
import 'package:pandaedu/domain/usecases/delete_flashcard.dart';
import 'package:pandaedu/domain/usecases/get_due_flashcards.dart';

void main() {
  group('Flashcard UseCases Tests', () {
    late FlashcardRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      repository = FlashcardRepositoryImpl(sharedPreferences);
    });

    group('CreateFlashcard UseCase', () {
      test('should create flashcard successfully', () async {
        final useCase = CreateFlashcard(repository);
        final flashcard = Flashcard(
          id: 'test-1',
          title: 'Test',
          transcript: 'Test content',
          audioPath: null,
          createdAt: DateTime.now(),
          duration: 5,
        );

        await useCase(flashcard);

        final allFlashcards = await repository.getAllFlashcards();
        expect(allFlashcards, hasLength(1));
        expect(allFlashcards.first.id, 'test-1');
      });
    });

    group('GetAllFlashcards UseCase', () {
      test('should get all flashcards', () async {
        final createUseCase = CreateFlashcard(repository);
        final getAllUseCase = GetAllFlashcards(repository);

        await createUseCase(Flashcard(
          id: '1',
          title: 'First',
          transcript: 'Content 1',
          audioPath: null,
          createdAt: DateTime.now(),
          duration: 5,
        ));

        await createUseCase(Flashcard(
          id: '2',
          title: 'Second',
          transcript: 'Content 2',
          audioPath: null,
          createdAt: DateTime.now(),
          duration: 5,
        ));

        final flashcards = await getAllUseCase();
        expect(flashcards, hasLength(2));
      });
    });

    group('UpdateFlashcard UseCase', () {
      test('should update flashcard successfully', () async {
        final createUseCase = CreateFlashcard(repository);
        final updateUseCase = UpdateFlashcard(repository);

        final original = Flashcard(
          id: 'update-1',
          title: 'Original',
          transcript: 'Original content',
          audioPath: null,
          createdAt: DateTime.now(),
          duration: 5,
        );

        await createUseCase(original);

        final updated = Flashcard(
          id: 'update-1',
          title: 'Updated',
          transcript: 'Updated content',
          audioPath: null,
          createdAt: original.createdAt,
          duration: 5,
        );

        await updateUseCase(updated);

        final result = await repository.getFlashcardById('update-1');
        expect(result!.title, 'Updated');
        expect(result.transcript, 'Updated content');
      });
    });

    group('DeleteFlashcard UseCase', () {
      test('should delete flashcard successfully', () async {
        final createUseCase = CreateFlashcard(repository);
        final deleteUseCase = DeleteFlashcard(repository);

        await createUseCase(Flashcard(
          id: 'delete-1',
          title: 'To Delete',
          transcript: 'Will be deleted',
          audioPath: null,
          createdAt: DateTime.now(),
          duration: 5,
        ));

        expect(await repository.getAllFlashcards(), hasLength(1));

        await deleteUseCase('delete-1');

        expect(await repository.getAllFlashcards(), isEmpty);
      });
    });

    group('GetDueFlashcards UseCase', () {
      test('should get only due flashcards', () async {
        final createUseCase = CreateFlashcard(repository);
        final getDueUseCase = GetDueFlashcards(repository);

        await createUseCase(Flashcard(
          id: 'due-1',
          title: 'Due',
          transcript: 'Due now',
          audioPath: null,
          createdAt: DateTime.now(),
          nextReviewAt: DateTime.now().subtract(const Duration(days: 1)),
          duration: 5,
        ));

        await createUseCase(Flashcard(
          id: 'not-due-1',
          title: 'Not Due',
          transcript: 'Not yet',
          audioPath: null,
          createdAt: DateTime.now(),
          nextReviewAt: DateTime.now().add(const Duration(days: 1)),
          duration: 5,
        ));

        final dueCards = await getDueUseCase();
        expect(dueCards, hasLength(1));
        expect(dueCards.first.id, 'due-1');
      });

      test('should include flashcards with null nextReviewAt as due', () async {
        final createUseCase = CreateFlashcard(repository);
        final getDueUseCase = GetDueFlashcards(repository);

        await createUseCase(Flashcard(
          id: 'never-reviewed',
          title: 'Never Reviewed',
          transcript: 'No review date',
          audioPath: null,
          createdAt: DateTime.now(),
          nextReviewAt: null,
          duration: 5,
        ));

        final dueCards = await getDueUseCase();
        expect(dueCards, hasLength(1));
      });
    });
  });
}
