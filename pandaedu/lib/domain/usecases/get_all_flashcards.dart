import '../entities/flashcard.dart';
import '../repositories/flashcard_repository.dart';

class GetAllFlashcards {
  final FlashcardRepository repository;

  GetAllFlashcards(this.repository);

  Future<List<Flashcard>> call() async {
    return await repository.getAllFlashcards();
  }
}
