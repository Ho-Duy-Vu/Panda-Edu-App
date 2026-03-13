import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../../core/constants.dart';
import '../models/flashcard_model.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final SharedPreferences sharedPreferences;

  FlashcardRepositoryImpl(this.sharedPreferences);

  @override
  Future<List<Flashcard>> getAllFlashcards() async {
    try {
      final jsonString = sharedPreferences.getString(StorageKeys.flashcardsKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => FlashcardModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all flashcards: $e');
      return [];
    }
  }

  @override
  Future<Flashcard?> getFlashcardById(String id) async {
    final flashcards = await getAllFlashcards();
    try {
      return flashcards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createFlashcard(Flashcard flashcard) async {
    try {
      final flashcards = await getAllFlashcards();
      final model = FlashcardModel.fromEntity(flashcard);
      flashcards.add(model);
      await _saveFlashcards(flashcards);
    } catch (e) {
      print('Error creating flashcard: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateFlashcard(Flashcard flashcard) async {
    try {
      final flashcards = await getAllFlashcards();
      final index = flashcards.indexWhere((card) => card.id == flashcard.id);
      if (index != -1) {
        final model = FlashcardModel.fromEntity(flashcard);
        flashcards[index] = model;
        await _saveFlashcards(flashcards);
      }
    } catch (e) {
      print('Error updating flashcard: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteFlashcard(String id) async {
    try {
      final flashcards = await getAllFlashcards();
      final flashcard = flashcards.firstWhere((card) => card.id == id);
      
      // Delete audio file if exists
      if (flashcard.audioPath != null && flashcard.audioPath!.isNotEmpty) {
        final audioFile = File(flashcard.audioPath!);
        if (await audioFile.exists()) {
          await audioFile.delete();
        }
      }

      flashcards.removeWhere((card) => card.id == id);
      await _saveFlashcards(flashcards);
    } catch (e) {
      print('Error deleting flashcard: $e');
      rethrow;
    }
  }

  @override
  Future<List<Flashcard>> getDueFlashcards() async {
    // Return all flashcards instead of filtering by nextReviewAt
    return await getAllFlashcards();
  }

  @override
  Future<List<Flashcard>> searchFlashcards(String query) async {
    final flashcards = await getAllFlashcards();
    final lowerQuery = query.toLowerCase();
    return flashcards.where((card) {
      return card.title.toLowerCase().contains(lowerQuery) ||
          card.transcript.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<void> _saveFlashcards(List<Flashcard> flashcards) async {
    final jsonList = flashcards
        .map((card) => FlashcardModel.fromEntity(card).toJson())
        .toList();
    await sharedPreferences.setString(
      StorageKeys.flashcardsKey,
      json.encode(jsonList),
    );
  }
}
