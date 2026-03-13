import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Migration script để cập nhật flashcards từ v1.0 → v1.1
/// Thêm các fields mới: collectionId, correctCount, incorrectCount
/// 
/// LƯU Ý: Script này KHÔNG BẮT BUỘC vì app đã backward compatible!
/// Chỉ chạy nếu muốn đảm bảo 100% data consistency.

class MigrateToV1_1 {
  static Future<void> migrate() async {
    print('🔄 [Migration] Starting migration to v1.1...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Migrate flashcards
      await _migrateFlashcards(prefs);
      
      // 2. Initialize collections (empty)
      await _initializeCollections(prefs);
      
      print('✅ [Migration] Migration completed successfully!');
    } catch (e) {
      print('❌ [Migration] Migration failed: $e');
      rethrow;
    }
  }

  static Future<void> _migrateFlashcards(SharedPreferences prefs) async {
    final flashcardsJson = prefs.getString('flashcards');
    
    if (flashcardsJson == null) {
      print('ℹ️ [Migration] No flashcards to migrate');
      return;
    }

    try {
      List<dynamic> flashcards = jsonDecode(flashcardsJson);
      int migratedCount = 0;
      
      for (var flashcard in flashcards) {
        bool needsUpdate = false;
        
        // Add collectionId if missing
        if (!flashcard.containsKey('collectionId')) {
          flashcard['collectionId'] = null;
          needsUpdate = true;
        }
        
        // Add correctCount if missing
        if (!flashcard.containsKey('correctCount')) {
          flashcard['correctCount'] = 0;
          needsUpdate = true;
        }
        
        // Add incorrectCount if missing
        if (!flashcard.containsKey('incorrectCount')) {
          flashcard['incorrectCount'] = 0;
          needsUpdate = true;
        }
        
        if (needsUpdate) {
          migratedCount++;
        }
      }
      
      // Save updated flashcards
      await prefs.setString('flashcards', jsonEncode(flashcards));
      
      print('✅ [Migration] Migrated $migratedCount flashcards');
    } catch (e) {
      print('❌ [Migration] Error migrating flashcards: $e');
      rethrow;
    }
  }

  static Future<void> _initializeCollections(SharedPreferences prefs) async {
    final collectionsJson = prefs.getString('collections');
    
    if (collectionsJson != null) {
      print('ℹ️ [Migration] Collections already exist, skipping initialization');
      return;
    }

    // Initialize with empty array
    await prefs.setString('collections', jsonEncode([]));
    print('✅ [Migration] Initialized empty collections');
  }

  /// Check if migration is needed
  static Future<bool> isMigrationNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final flashcardsJson = prefs.getString('flashcards');
      
      if (flashcardsJson == null) return false;
      
      List<dynamic> flashcards = jsonDecode(flashcardsJson);
      
      if (flashcards.isEmpty) return false;
      
      // Check first flashcard
      final first = flashcards[0];
      return !first.containsKey('collectionId') ||
             !first.containsKey('correctCount') ||
             !first.containsKey('incorrectCount');
    } catch (e) {
      return false;
    }
  }
}

/// Example usage:
/// 
/// In main.dart, before runApp:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // Check and migrate if needed
///   if (await MigrateToV1_1.isMigrationNeeded()) {
///     await MigrateToV1_1.migrate();
///   }
///   
///   final prefs = await SharedPreferences.getInstance();
///   runApp(PandaEduApp(prefs: prefs));
/// }
/// ```

