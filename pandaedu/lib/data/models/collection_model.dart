import '../../domain/entities/collection.dart';

class CollectionModel extends Collection {
  const CollectionModel({
    required super.id,
    required super.name,
    super.description,
    required super.createdAt,
    super.flashcardCount,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      flashcardCount: json['flashcardCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'flashcardCount': flashcardCount,
    };
  }

  factory CollectionModel.fromEntity(Collection collection) {
    return CollectionModel(
      id: collection.id,
      name: collection.name,
      description: collection.description,
      createdAt: collection.createdAt,
      flashcardCount: collection.flashcardCount,
    );
  }
}

