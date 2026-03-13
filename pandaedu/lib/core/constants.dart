import 'package:flutter/material.dart';

// Storage Keys
class StorageKeys {
  static const String flashcardsKey = 'flashcards_v1';
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
}

// Color Palette
class AppColors {
  static const Color matchaLight = Color(0xFFA8D5BA);
  static const Color matchaMedium = Color(0xFF7FB899);
  static const Color matchaDark = Color(0xFF4A7C59);
  static const Color matchaDeep = Color(0xFF6BBF59);
  static const Color milkWhite = Color(0xFFF9FDF7);
  static const Color pandaBlack = Color(0xFF2C2C2C);
  static const Color pandaWhite = Color(0xFFFAFAFA);
  static const Color accentOrange = Color(0xFFFF6F61);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA726);
}

// Sizing & Spacing
class AppSizes {
  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Padding
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Touch targets
  static const double minTouchTarget = 48.0;
  static const double recordButtonSize = 160.0;
}

// Validation Rules
class FlashcardValidator {
  static const int minTitleLength = 1;
  static const int maxTitleLength = 100;
  static const int minTranscriptLength = 1;
  static const int maxTranscriptLength = 5000;
  static const int maxRecordingDurationSeconds = 60;
  static const int minRecordingDurationSeconds = 1;
  static const int maxFlashcards = 1000;
  static const int maxAudioSizeMB = 10;

  static String? validateTitle(String title) {
    if (title.trim().isEmpty) {
      return 'Vui lòng nhập tiêu đề';
    }
    if (title.length > maxTitleLength) {
      return 'Tiêu đề không được quá $maxTitleLength ký tự';
    }
    return null;
  }

  static String? validateTranscript(String transcript) {
    if (transcript.trim().isEmpty) {
      return 'Vui lòng nhập nội dung';
    }
    if (transcript.length > maxTranscriptLength) {
      return 'Nội dung không được quá $maxTranscriptLength ký tự';
    }
    return null;
  }
}
