import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/collection_repository.dart';
import '../models/collection_model.dart';
import '../../core/constants.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final SharedPreferences prefs;

  CollectionRepositoryImpl({required this.prefs});

  static const String _collectionsKey = 'collections';

  @override
  Future<List<Collection>> getAllCollections() async {
    try {
      final jsonString = prefs.getString(_collectionsKey);
      if (jsonString == null) return <Collection>[];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => CollectionModel.fromJson(json as Map<String, dynamic>) as Collection)
          .toList();
    } catch (e) {
      print('Error loading collections: $e');
      return <Collection>[];
    }
  }

  @override
  Future<Collection?> getCollectionById(String id) async {
    final collections = await getAllCollections();
    try {
      return collections.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createCollection(Collection collection) async {
    final collections = List<Collection>.from(await getAllCollections());
    collections.add(collection);
    await _saveCollections(collections);
  }

  @override
  Future<void> updateCollection(Collection collection) async {
    final collections = List<Collection>.from(await getAllCollections());
    final index = collections.indexWhere((c) => c.id == collection.id);
    
    if (index != -1) {
      collections[index] = collection;
      await _saveCollections(collections);
    }
  }

  @override
  Future<void> deleteCollection(String id) async {
    final collections = List<Collection>.from(await getAllCollections());
    collections.removeWhere((c) => c.id == id);
    await _saveCollections(collections);
  }

  @override
  Future<int> getFlashcardCountInCollection(String collectionId) async {
    try {
      final flashcardsJson = prefs.getString(StorageKeys.flashcardsKey);
      if (flashcardsJson == null) return 0;

      final List<dynamic> flashcards = jsonDecode(flashcardsJson);
      return flashcards.where((f) => f['collectionId'] == collectionId).length;
    } catch (e) {
      print('Error counting flashcards: $e');
      return 0;
    }
  }

  Future<void> _saveCollections(List<Collection> collections) async {
    final jsonList = collections
        .map((c) => CollectionModel.fromEntity(c).toJson())
        .toList();
    await prefs.setString(_collectionsKey, jsonEncode(jsonList));
  }
}

