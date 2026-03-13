import '../entities/flashcard.dart';
import '../repositories/flashcard_repository.dart';

class CreateFlashcard {
  final FlashcardRepository repository;

  CreateFlashcard(this.repository);

  Future<void> call(Flashcard flashcard) async {
    await repository.createFlashcard(flashcard);
  }
}
