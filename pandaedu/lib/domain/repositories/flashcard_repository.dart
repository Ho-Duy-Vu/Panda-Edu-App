import '../entities/flashcard.dart';

abstract class FlashcardRepository {
  Future<List<Flashcard>> getAllFlashcards();
  Future<Flashcard?> getFlashcardById(String id);
  Future<void> createFlashcard(Flashcard flashcard);
  Future<void> updateFlashcard(Flashcard flashcard);
  Future<void> deleteFlashcard(String id);
  Future<List<Flashcard>> getDueFlashcards();
  Future<List<Flashcard>> searchFlashcards(String query);
}
