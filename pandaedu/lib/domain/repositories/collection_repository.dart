import '../entities/collection.dart';

abstract class CollectionRepository {
  Future<List<Collection>> getAllCollections();
  Future<Collection?> getCollectionById(String id);
  Future<void> createCollection(Collection collection);
  Future<void> updateCollection(Collection collection);
  Future<void> deleteCollection(String id);
  Future<int> getFlashcardCountInCollection(String collectionId);
}

