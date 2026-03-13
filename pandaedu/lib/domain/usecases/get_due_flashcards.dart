import '../entities/flashcard.dart';
import '../repositories/flashcard_repository.dart';

class GetDueFlashcards {
  final FlashcardRepository repository;

  GetDueFlashcards(this.repository);

  Future<List<Flashcard>> call() async {
    return await repository.getDueFlashcards();
  }
}
