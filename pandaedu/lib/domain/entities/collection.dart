import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final int flashcardCount;

  const Collection({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.flashcardCount = 0,
  });

  Collection copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    int? flashcardCount,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      flashcardCount: flashcardCount ?? this.flashcardCount,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdAt, flashcardCount];
}

