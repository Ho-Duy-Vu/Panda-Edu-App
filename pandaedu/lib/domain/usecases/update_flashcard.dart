import '../entities/flashcard.dart';
import '../repositories/flashcard_repository.dart';

class UpdateFlashcard {
  final FlashcardRepository repository;

  UpdateFlashcard(this.repository);

  Future<void> call(Flashcard flashcard) async {
    await repository.updateFlashcard(flashcard);
  }
}
