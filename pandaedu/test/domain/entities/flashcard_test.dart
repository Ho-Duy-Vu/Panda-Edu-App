import 'package:flutter_test/flutter_test.dart';
import 'package:pandaedu/domain/entities/flashcard.dart';
import 'package:pandaedu/data/models/flashcard_model.dart';

void main() {
  group('Flashcard Entity Tests', () {
    test('should create flashcard with required fields', () {
      final flashcard = Flashcard(
        id: 'test-1',
        title: 'Test Title',
        transcript: 'Test Transcript',
        audioPath: null,
        createdAt: DateTime(2025, 12, 10),
        duration: 5,
      );

      expect(flashcard.id, 'test-1');
      expect(flashcard.title, 'Test Title');
      expect(flashcard.transcript, 'Test Transcript');
      expect(flashcard.audioPath, isNull);
      expect(flashcard.repeatLevel, 0);
      expect(flashcard.favorite, false);
    });

    test('should create flashcard with all fields', () {
      final createdAt = DateTime(2025, 12, 10);
      final nextReviewAt = DateTime(2025, 12, 15);

      final flashcard = Flashcard(
        id: 'test-2',
        title: 'Full Card',
        transcript: 'Complete content',
        audioPath: '/path/to/audio.m4a',
        createdAt: createdAt,
        nextReviewAt: nextReviewAt,
        repeatLevel: 3,
        favorite: true,
        duration: 10,
      );

      expect(flashcard.id, 'test-2');
      expect(flashcard.title, 'Full Card');
      expect(flashcard.transcript, 'Complete content');
      expect(flashcard.audioPath, '/path/to/audio.m4a');
      expect(flashcard.createdAt, createdAt);
      expect(flashcard.nextReviewAt, nextReviewAt);
      expect(flashcard.repeatLevel, 3);
      expect(flashcard.favorite, true);
      expect(flashcard.duration, 10);
    });

    test('should support equality comparison', () {
      final flashcard1 = Flashcard(
        id: 'test-3',
        title: 'Same',
        transcript: 'Same',
        audioPath: null,
        createdAt: DateTime(2025, 12, 10),
        duration: 5,
      );

      final flashcard2 = Flashcard(
        id: 'test-3',
        title: 'Same',
        transcript: 'Same',
        audioPath: null,
        createdAt: DateTime(2025, 12, 10),
        duration: 5,
      );

      expect(flashcard1, equals(flashcard2));
    });

    test('should be different with different ids', () {
      final flashcard1 = Flashcard(
        id: 'test-4',
        title: 'Same',
        transcript: 'Same',
        audioPath: null,
        createdAt: DateTime(2025, 12, 10),
        duration: 5,
      );

      final flashcard2 = Flashcard(
        id: 'test-5',
        title: 'Same',
        transcript: 'Same',
        audioPath: null,
        createdAt: DateTime(2025, 12, 10),
        duration: 5,
      );

      expect(flashcard1, isNot(equals(flashcard2)));
    });
  });

  group('FlashcardModel Tests', () {
    test('should convert from JSON correctly', () {
      final json = {
        'id': 'json-1',
        'title': 'JSON Title',
        'transcript': 'JSON Content',
        'audioPath': '/path/to/audio.m4a',
        'createdAt': '2025-12-10T10:30:00.000Z',
        'nextReviewAt': '2025-12-15T10:30:00.000Z',
        'repeatLevel': 2,
        'favorite': true,
        'duration': 8,
      };

      final model = FlashcardModel.fromJson(json);

      expect(model.id, 'json-1');
      expect(model.title, 'JSON Title');
      expect(model.transcript, 'JSON Content');
      expect(model.audioPath, '/path/to/audio.m4a');
      expect(model.repeatLevel, 2);
      expect(model.favorite, true);
      expect(model.duration, 8);
    });

    test('should convert to JSON correctly', () {
      final model = FlashcardModel(
        id: 'model-1',
        title: 'Model Title',
        transcript: 'Model Content',
        audioPath: '/audio.m4a',
        createdAt: DateTime(2025, 12, 10, 10, 30),
        nextReviewAt: DateTime(2025, 12, 15, 10, 30),
        repeatLevel: 3,
        favorite: true,
        duration: 12,
      );

      final json = model.toJson();

      expect(json['id'], 'model-1');
      expect(json['title'], 'Model Title');
      expect(json['transcript'], 'Model Content');
      expect(json['audioPath'], '/audio.m4a');
      expect(json['repeatLevel'], 3);
      expect(json['favorite'], true);
      expect(json['duration'], 12);
      expect(json['createdAt'], isNotNull);
      expect(json['nextReviewAt'], isNotNull);
    });

    test('should handle null audioPath in JSON', () {
      final json = {
        'id': 'json-2',
        'title': 'No Audio',
        'transcript': 'No audio content',
        'audioPath': null,
        'createdAt': '2025-12-10T10:30:00.000Z',
        'duration': 5,
      };

      final model = FlashcardModel.fromJson(json);

      expect(model.audioPath, isNull);
      expect(model.repeatLevel, 0);
      expect(model.favorite, false);
    });

    test('should convert from entity correctly', () {
      final entity = Flashcard(
        id: 'entity-1',
        title: 'Entity Title',
        transcript: 'Entity Content',
        audioPath: '/entity/audio.m4a',
        createdAt: DateTime(2025, 12, 10),
        nextReviewAt: DateTime(2025, 12, 15),
        repeatLevel: 4,
        favorite: true,
        duration: 15,
      );

      final model = FlashcardModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.transcript, entity.transcript);
      expect(model.audioPath, entity.audioPath);
      expect(model.createdAt, entity.createdAt);
      expect(model.nextReviewAt, entity.nextReviewAt);
      expect(model.repeatLevel, entity.repeatLevel);
      expect(model.favorite, entity.favorite);
      expect(model.duration, entity.duration);
    });

    test('should serialize and deserialize correctly', () {
      final original = FlashcardModel(
        id: 'roundtrip-1',
        title: 'Roundtrip',
        transcript: 'Test roundtrip',
        audioPath: '/audio.m4a',
        createdAt: DateTime(2025, 12, 10, 10, 30),
        nextReviewAt: DateTime(2025, 12, 15, 10, 30),
        repeatLevel: 2,
        favorite: true,
        duration: 7,
      );

      final json = original.toJson();
      final deserialized = FlashcardModel.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.title, original.title);
      expect(deserialized.transcript, original.transcript);
      expect(deserialized.audioPath, original.audioPath);
      expect(deserialized.repeatLevel, original.repeatLevel);
      expect(deserialized.favorite, original.favorite);
      expect(deserialized.duration, original.duration);
    });
  });
}
