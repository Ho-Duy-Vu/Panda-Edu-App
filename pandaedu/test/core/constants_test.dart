import 'package:flutter_test/flutter_test.dart';
import 'package:pandaedu/core/constants.dart';

void main() {
  group('FlashcardValidator Tests', () {
    group('validateTitle', () {
      test('should return null for valid title', () {
        expect(FlashcardValidator.validateTitle('Valid Title'), isNull);
        expect(FlashcardValidator.validateTitle('A'), isNull);
        expect(FlashcardValidator.validateTitle('a' * 100), isNull);
      });

      test('should return error for empty title', () {
        expect(FlashcardValidator.validateTitle(''), isNotNull);
      });

      test('should return error for title too long', () {
        expect(FlashcardValidator.validateTitle('a' * 101), isNotNull);
      });
    });

    group('validateTranscript', () {
      test('should return null for valid transcript', () {
        expect(FlashcardValidator.validateTranscript('Valid content'), isNull);
        expect(FlashcardValidator.validateTranscript('A'), isNull);
        expect(FlashcardValidator.validateTranscript('a' * 5000), isNull);
      });

      test('should return error for empty transcript', () {
        expect(FlashcardValidator.validateTranscript(''), isNotNull);
      });

      test('should return error for transcript too long', () {
        expect(FlashcardValidator.validateTranscript('a' * 5001), isNotNull);
      });
    });

    group('Constants', () {
      test('should have correct validation limits', () {
        expect(FlashcardValidator.minTitleLength, 1);
        expect(FlashcardValidator.maxTitleLength, 100);
        expect(FlashcardValidator.minTranscriptLength, 1);
        expect(FlashcardValidator.maxTranscriptLength, 5000);
      });

      test('should have correct recording limits', () {
        expect(FlashcardValidator.maxRecordingDurationSeconds, 60);
        expect(FlashcardValidator.minRecordingDurationSeconds, 1);
      });

      test('should have correct storage limits', () {
        expect(FlashcardValidator.maxFlashcards, 1000);
        expect(FlashcardValidator.maxAudioSizeMB, 10);
      });
    });
  });

  group('AppColors Tests', () {
    test('should have all required colors defined', () {
      expect(AppColors.matchaLight, isNotNull);
      expect(AppColors.matchaMedium, isNotNull);
      expect(AppColors.matchaDeep, isNotNull);
      expect(AppColors.milkWhite, isNotNull);
      expect(AppColors.pandaBlack, isNotNull);
      expect(AppColors.accentOrange, isNotNull);
      expect(AppColors.success, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.warning, isNotNull);
    });
  });

  group('AppSizes Tests', () {
    test('should have all required sizes defined', () {
      expect(AppSizes.radiusSmall, 8.0);
      expect(AppSizes.radiusMedium, 12.0);
      expect(AppSizes.radiusLarge, 16.0);
      expect(AppSizes.radiusXLarge, 24.0);
      expect(AppSizes.paddingSmall, 8.0);
      expect(AppSizes.paddingMedium, 16.0);
      expect(AppSizes.paddingLarge, 24.0);
    });

    test('should have correct touch target sizes', () {
      expect(AppSizes.minTouchTarget, 48.0);
      expect(AppSizes.recordButtonSize, greaterThanOrEqualTo(48.0));
    });
  });

  group('StorageKeys Tests', () {
    test('should have all required storage keys', () {
      expect(StorageKeys.flashcardsKey, 'flashcards_v1');
      expect(StorageKeys.themeKey, 'app_theme');
      expect(StorageKeys.hasSeenOnboarding, 'has_seen_onboarding');
      expect(StorageKeys.languageKey, 'app_language');
    });
  });
}
