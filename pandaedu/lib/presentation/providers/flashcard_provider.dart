import 'package:flutter/material.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../../domain/usecases/create_flashcard.dart';
import '../../domain/usecases/get_all_flashcards.dart';
import '../../domain/usecases/get_due_flashcards.dart';
import '../../domain/usecases/update_flashcard.dart';
import '../../domain/usecases/delete_flashcard.dart';

class FlashcardProvider extends ChangeNotifier {
  final FlashcardRepository repository;
  late final CreateFlashcard _createFlashcard;
  late final GetAllFlashcards _getAllFlashcards;
  late final GetDueFlashcards _getDueFlashcards;
  late final UpdateFlashcard _updateFlashcard;
  late final DeleteFlashcard _deleteFlashcard;

  List<Flashcard> _flashcards = [];
  List<Flashcard> _filteredFlashcards = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'newest'; // 'newest', 'name'
  String? _filterByCollectionId; // null = all, 'uncategorized' = null collection

  FlashcardProvider(this.repository) {
    _createFlashcard = CreateFlashcard(repository);
    _getAllFlashcards = GetAllFlashcards(repository);
    _getDueFlashcards = GetDueFlashcards(repository);
    _updateFlashcard = UpdateFlashcard(repository);
    _deleteFlashcard = DeleteFlashcard(repository);
    loadFlashcards();
  }

  List<Flashcard> get flashcards => _filteredFlashcards;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  String? get filterByCollectionId => _filterByCollectionId;

  Future<void> loadFlashcards() async {
    _isLoading = true;
    notifyListeners();

    try {
      _flashcards = await _getAllFlashcards();
      _applyFiltersAndSort();
    } catch (e) {
      print('Error loading flashcards: $e');
      _flashcards = [];
      _filteredFlashcards = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createFlashcard(Flashcard flashcard) async {
    try {
      await _createFlashcard(flashcard);
      await loadFlashcards();
    } catch (e) {
      print('Error creating flashcard: $e');
      rethrow;
    }
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    try {
      await _updateFlashcard(flashcard);
      await loadFlashcards();
    } catch (e) {
      print('Error updating flashcard: $e');
      rethrow;
    }
  }

  Future<void> deleteFlashcard(String id) async {
    try {
      await _deleteFlashcard(id);
      await loadFlashcards();
    } catch (e) {
      print('Error deleting flashcard: $e');
      rethrow;
    }
  }

  Future<List<Flashcard>> getDueFlashcards() async {
    return await _getDueFlashcards();
  }

  Flashcard? getFlashcardById(String id) {
    try {
      return _flashcards.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setCollectionFilter(String? collectionId) {
    _filterByCollectionId = collectionId;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearCollectionFilter() {
    _filterByCollectionId = null;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    _filteredFlashcards = List.from(_flashcards);

    // Apply collection filter
    if (_filterByCollectionId == 'uncategorized') {
      _filteredFlashcards = _filteredFlashcards
          .where((card) => card.collectionId == null)
          .toList();
    } else if (_filterByCollectionId != null) {
      _filteredFlashcards = _filteredFlashcards
          .where((card) => card.collectionId == _filterByCollectionId)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredFlashcards = _filteredFlashcards.where((card) {
        return card.title.toLowerCase().contains(lowerQuery) ||
            card.transcript.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'newest':
        _filteredFlashcards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'name':
        _filteredFlashcards.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
  }

  Future<void> toggleFavorite(Flashcard flashcard) async {
    final updated = flashcard.copyWith(favorite: !flashcard.favorite);
    await updateFlashcard(updated);
  }
}
