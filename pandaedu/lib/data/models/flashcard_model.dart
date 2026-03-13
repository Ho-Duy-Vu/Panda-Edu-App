import '../../domain/entities/flashcard.dart';

class FlashcardModel extends Flashcard {
  const FlashcardModel({
    required super.id,
    required super.title,
    required super.transcript,
    super.audioPath,
    required super.createdAt,
    super.favorite,
    required super.duration,
    super.collectionId,
    super.correctCount,
    super.incorrectCount,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      transcript: json['transcript'] as String,
      audioPath: json['audioPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      favorite: json['favorite'] as bool? ?? false,
      duration: json['duration'] as int,
      collectionId: json['collectionId'] as String?,
      correctCount: json['correctCount'] as int? ?? 0,
      incorrectCount: json['incorrectCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'transcript': transcript,
      'audioPath': audioPath,
      'createdAt': createdAt.toIso8601String(),
      'favorite': favorite,
      'duration': duration,
      'collectionId': collectionId,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
    };
  }

  factory FlashcardModel.fromEntity(Flashcard flashcard) {
    return FlashcardModel(
      id: flashcard.id,
      title: flashcard.title,
      transcript: flashcard.transcript,
      audioPath: flashcard.audioPath,
      createdAt: flashcard.createdAt,
      favorite: flashcard.favorite,
      duration: flashcard.duration,
      collectionId: flashcard.collectionId,
      correctCount: flashcard.correctCount,
      incorrectCount: flashcard.incorrectCount,
    );
  }
}
