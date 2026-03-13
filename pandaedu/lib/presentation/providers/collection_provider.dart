import 'package:flutter/material.dart';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/collection_repository.dart';

class CollectionProvider extends ChangeNotifier {
  final CollectionRepository repository;
  List<Collection> _collections = [];
  bool _isLoading = false;
  String? _errorMessage;

  CollectionProvider({required this.repository});

  List<Collection> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all collections
  Future<void> loadCollections() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _collections = await repository.getAllCollections();
      
      // Update flashcard counts for each collection
      for (int i = 0; i < _collections.length; i++) {
        final count = await repository.getFlashcardCountInCollection(_collections[i].id);
        _collections[i] = _collections[i].copyWith(flashcardCount: count);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải collections: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get collection by ID
  Future<Collection?> getCollectionById(String id) async {
    return await repository.getCollectionById(id);
  }

  // Create new collection
  Future<void> createCollection(Collection collection) async {
    try {
      await repository.createCollection(collection);
      await loadCollections(); // Reload to update UI
    } catch (e) {
      _errorMessage = 'Không thể tạo collection: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update collection
  Future<void> updateCollection(Collection collection) async {
    try {
      await repository.updateCollection(collection);
      await loadCollections(); // Reload to update UI
    } catch (e) {
      _errorMessage = 'Không thể cập nhật collection: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Delete collection
  Future<void> deleteCollection(String id) async {
    try {
      await repository.deleteCollection(id);
      await loadCollections(); // Reload to update UI
    } catch (e) {
      _errorMessage = 'Không thể xóa collection: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Get flashcard count in collection
  Future<int> getFlashcardCount(String collectionId) async {
    return await repository.getFlashcardCountInCollection(collectionId);
  }

  // Sort collections
  void sortCollections(String sortBy) {
    switch (sortBy) {
      case 'name':
        _collections.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'count':
        _collections.sort((a, b) => b.flashcardCount.compareTo(a.flashcardCount));
        break;
      case 'newest':
        _collections.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        _collections.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
    notifyListeners();
  }
}

