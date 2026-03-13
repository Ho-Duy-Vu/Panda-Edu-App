import 'package:equatable/equatable.dart';

class Flashcard extends Equatable {
  final String id;
  final String title;
  final String transcript;
  final String? audioPath;
  final DateTime createdAt;
  final bool favorite;
  final int duration; // in seconds
  final String? collectionId; // ID của collection chứa flashcard này
  final int correctCount; // Số lần trả lời đúng
  final int incorrectCount; // Số lần trả lời sai

  const Flashcard({
    required this.id,
    required this.title,
    required this.transcript,
    this.audioPath,
    required this.createdAt,
    this.favorite = false,
    required this.duration,
    this.collectionId,
    this.correctCount = 0,
    this.incorrectCount = 0,
  });

  Flashcard copyWith({
    String? id,
    String? title,
    String? transcript,
    String? audioPath,
    DateTime? createdAt,
    bool? favorite,
    int? duration,
    String? collectionId,
    int? correctCount,
    int? incorrectCount,
  }) {
    return Flashcard(
      id: id ?? this.id,
      title: title ?? this.title,
      transcript: transcript ?? this.transcript,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      favorite: favorite ?? this.favorite,
      duration: duration ?? this.duration,
      collectionId: collectionId ?? this.collectionId,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        transcript,
        audioPath,
        createdAt,
        favorite,
        duration,
        collectionId,
        correctCount,
        incorrectCount,
      ];
}
