# Đánh giá và Điều chỉnh Prompt Build App Flutter

## 📋 Tổng quan
Prompt này là một yêu cầu chi tiết để xây dựng một ứng dụng Flutter voice-note flashcards. Sau khi phân tích, tôi đánh giá prompt **CƠ BẢN ĐÃ ĐẦY ĐỦ** nhưng cần bổ sung và làm rõ một số điểm quan trọng.

---

## ✅ ĐIỂM MẠNH

### 1. Kiến trúc rõ ràng
- ✅ Yêu cầu Clean Architecture với SOLID principles
- ✅ Phân tách rõ ràng domain/data/presentation layers
- ✅ Repository pattern được định nghĩa

### 2. Chi tiết kỹ thuật
- ✅ Tech stack cụ thể (Flutter, Dart 3, packages)
- ✅ Android SDK versions (35/23)
- ✅ State management (Provider/Riverpod)
- ✅ Storage solution (SharedPreferences)

### 3. UI/UX Design System
- ✅ Color palette cụ thể (Matcha/Panda theme)
- ✅ Font preferences (Poppins/Nunito)
- ✅ Child-friendly guidelines (5+ age group)
- ✅ Dark mode support

### 4. Cấu trúc dự án
- ✅ Folder structure chi tiết
- ✅ File naming conventions
- ✅ Asset organization

### 5. Data Model
- ✅ JSON schema cụ thể cho flashcard
- ✅ SharedPreferences keys defined
- ✅ Audio file path conventions

---

## ⚠️ CÁC VẤN ĐỀ CẦN ĐIỀU CHỈNH

### 🔴 **CRITICAL ISSUES** (Phải sửa)

#### 1. **Thiếu chi tiết về Speech-to-Text (STT)**
**Vấn đề:** Prompt đề cập "optional live STT placeholder" nhưng không rõ:
- Có implement STT thật hay chỉ là placeholder?
- Nếu có, dùng package nào? (speech_to_text, google_speech?)
- Offline hay online STT?

**Đề xuất bổ sung:**
```markdown
STT IMPLEMENTATION:
- Use speech_to_text package for voice recognition
- Implement offline basic recognition (if available)
- Fallback: Manual text input if STT unavailable
- Show loading indicator during transcription
- Error handling for STT failures
```

#### 2. **Audio Recording Permissions không đủ chi tiết**
**Vấn đề:** Chỉ đề cập "manage permissions" trong Settings nhưng không có:
- Permission handling flow (request, denied, permanently denied)
- AndroidManifest.xml permissions cần thiết
- iOS Info.plist entries

**Đề xuất bổ sung:**
```markdown
PERMISSIONS CONFIGURATION:
Android (android/app/src/main/AndroidManifest.xml):
- <uses-permission android:name="android.permission.RECORD_AUDIO"/>
- <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
- <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

iOS (ios/Runner/Info.plist):
- NSMicrophoneUsageDescription: "Để ghi âm tạo flashcard"
- NSSpeechRecognitionUsageDescription: "Để chuyển giọng nói thành văn bản"

Runtime permission handling:
- Use permission_handler package
- Implement PermissionService in core/
- Request on first record attempt
- Show educational dialog before requesting
- Handle denied/permanently denied states
```

#### 3. **Study Mode - Spaced Repetition Algorithm không rõ ràng**
**Vấn đề:** Chỉ nói "0, 1 day, 3 days, 7 days" nhưng không có:
- Logic cụ thể khi nào tăng/giảm level
- Công thức tính nextReviewDate
- Xử lý khi user trả lời đúng/sai

**Đề xuất bổ sung:**
```markdown
SPACED REPETITION ALGORITHM:
repeatLevel intervals:
- Level 0: Review immediately (new card)
- Level 1: +1 day
- Level 2: +3 days
- Level 3: +7 days
- Level 4: +14 days
- Level 5+: +30 days

Update logic:
- Correct answer: repeatLevel++, nextReviewAt = now + interval
- Wrong answer: repeatLevel = max(0, repeatLevel - 1)
- Skip: no change

Filtering:
- getDueFlashcards(): where nextReviewAt <= now OR nextReviewAt == null
- StudyPage shows only due cards
```

#### 4. **Audio Quiz - Multiple Choice Generation Logic thiếu**
**Vấn đề:** Nói "3 options" nhưng không rõ:
- Làm sao tạo các lựa chọn sai từ đâu?
- Random từ flashcards khác?
- Hardcoded list?

**Đề xuất bổ sung:**
```markdown
AUDIO QUIZ GENERATION:
- Correct answer: current flashcard's transcript
- Wrong answers (2): 
  - Randomly select from other flashcards' transcripts
  - If <3 flashcards total, show message "Need at least 3 cards to play quiz"
- Shuffle all 3 options randomly
- Track user selection and show immediate feedback (panda happy/sad)
```

### 🟡 **IMPORTANT ISSUES** (Nên sửa)

#### 5. **Backup/Export-Import không đủ chi tiết**
**Vấn đề:** Chỉ nói "export/import JSON" nhưng không có:
- Format file export
- Audio files có được export không?
- Restore flow

**Đề xuất bổ sung:**
```markdown
BACKUP FEATURE:
Export format:
{
  "version": "1.0.0",
  "exportedAt": "ISO8601",
  "flashcards": [...],
  "settings": {...}
}

Export process:
- Create JSON file in Downloads/
- Optional: Create ZIP with audio files (future feature)
- Show success toast with file path

Import process:
- File picker to select .json file
- Validate JSON structure
- Confirm dialog: "This will replace all current data"
- Merge strategy: replace or append (user choice)
```

#### 6. **Onboarding Slides nội dung không cụ thể**
**Vấn đề:** Chỉ nói "3 slides" nhưng không có content

**Đề xuất bổ sung:**
```markdown
ONBOARDING CONTENT:
Slide 1:
- Title: "Chào bạn! 🐼"
- Subtitle: "Ghi âm và học với flashcard vui vẻ"
- Image: Panda waving

Slide 2:
- Title: "Ghi âm dễ dàng 🎤"
- Subtitle: "Nhấn nút đỏ để ghi lại giọng nói của bạn"
- Image: Panda with microphone

Slide 3:
- Title: "Ôn tập thông minh 📚"
- Subtitle: "Ứng dụng sẽ nhắc bạn ôn đúng lúc"
- Image: Panda with books
- CTA Button: "Bắt đầu thôi!"
```

#### 7. **Error Handling Strategy thiếu**
**Vấn đề:** Không đề cập xử lý lỗi toàn cục

**Đề xuất bổ sung:**
```markdown
ERROR HANDLING:
- Implement Result<T> or Either<L,R> pattern in domain layer
- Common errors:
  - StorageException (SharedPreferences failures)
  - AudioException (recording/playback failures)
  - PermissionDeniedException
  - ValidationException

- User-facing error messages:
  - SnackBar for transient errors
  - Dialog for critical errors requiring action
  - Panda sad illustration for empty/error states
  - Vietnamese error messages in l10n
```

#### 8. **Validation Rules thiếu**
**Đề xuất bổ sung:**
```markdown
VALIDATION RULES:
Flashcard creation:
- Title: 1-100 characters, required
- Transcript: 1-500 characters, required (or empty if STT failed)
- Audio file: must exist and be <10MB
- Duplicate title: warn but allow

Audio recording:
- Min duration: 1 second
- Max duration: 60 seconds
- Format: m4a, 44.1kHz recommended
```

### 🟢 **NICE TO HAVE** (Nên có thêm)

#### 9. **Performance Considerations**
**Đề xuất bổ sung:**
```markdown
PERFORMANCE:
- Limit flashcards list to 1000 items (show warning at 900)
- Audio files: auto-compress if >5MB
- Pagination: show 20 items initially, load more on scroll
- Image assets: use .webp format for smaller size
- Debounce search/filter operations (300ms)
```

#### 10. **Analytics & Logging (Optional)**
**Đề xuất bổ sung:**
```markdown
LOGGING (Development only):
- Use logger package
- Log levels: debug, info, warning, error
- DO NOT log sensitive data (audio content, user text)
- Implement in core/logger.dart

Future: Firebase Analytics (not in v1.0.0-beta)
```

#### 11. **Accessibility - Cụ thể hơn**
**Đề xuất bổ sung:**
```markdown
ACCESSIBILITY ENHANCEMENTS:
- Minimum touch target: 48x48 dp
- Semantic labels for all interactive widgets
- Screen reader support (Talkback/VoiceOver)
- High contrast mode compatibility
- Font scaling support (up to 2x)
- Focus indicators for keyboard navigation
```

#### 12. **Testing - Mở rộng**
**Đề xuất bổ sung:**
```markdown
TESTING REQUIREMENTS:
Unit tests (minimum):
- ✅ CreateFlashcardUsecase (as mentioned)
- ✅ GetFlashcardsUsecase
- ✅ UpdateFlashcardUsecase
- ✅ SharedPrefsRepository CRUD operations
- ✅ SpacedRepetitionService.calculateNextReview()

Widget tests (minimum):
- ✅ FlashcardTile (as mentioned)
- ✅ HomePage empty state
- ✅ RecordPage button interaction
- ✅ Settings theme toggle

Integration test:
- ✅ Full flow: Onboarding → Record → Save → Study
```

---

## 🔧 CÁC PACKAGE BỔ SUNG CẦN THIẾT

Prompt hiện tại thiếu một số packages quan trọng:

```yaml
dependencies:
  # ✅ Đã có
  flutter_localizations:
  shared_preferences:
  provider: # hoặc riverpod
  record:
  just_audio:
  flutter_launcher_icons:
  path_provider:
  uuid:
  intl:
  
  # ⚠️ CẦN BỔ SUNG
  permission_handler: ^11.0.1  # Xử lý permissions
  file_picker: ^6.0.0  # Import backup file
  share_plus: ^7.2.1  # Share flashcards (future)
  flutter_svg: ^2.0.9  # Nếu dùng SVG cho Panda
  logger: ^2.0.2  # Logging
  equatable: ^2.0.5  # Value equality cho entities
  
  # 🟢 OPTIONAL (Nice to have)
  speech_to_text: ^6.5.1  # Nếu implement STT thật
  connectivity_plus: ^5.0.2  # Check network (future online features)
  image_picker: ^1.0.5  # Future: add images to flashcards
```

---

## 📝 BỔ SUNG VỀ ANDROID CONFIG

Prompt đã có signing config nhưng thiếu:

```markdown
ANDROID ADDITIONAL CONFIG:

1. android/app/src/main/AndroidManifest.xml:
   - Add permissions (đã đề cập ở trên)
   - Add android:requestLegacyExternalStorage="true" (for Android 10)
   - Set android:label="Voice Flashcards"

2. android/app/build.gradle:
   - Ensure namespace 'com.example.voice_note_flashcards'
   - Add proguard rules for release:
     ```
     buildTypes {
         release {
             signingConfig signingConfigs.release
             minifyEnabled true
             shrinkResources true
             proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
         }
     }
     ```

3. Create android/app/proguard-rules.pro:
   ```
   -keep class com.example.voice_note_flashcards.** { *; }
   -keep class io.flutter.** { *; }
   ```
```

---

## 🎯 BỔ SUNG VỀ IOS CONFIG (Prompt thiếu hoàn toàn)

```markdown
IOS CONFIGURATION (REQUIRED):

1. ios/Runner/Info.plist - Add permissions:
   <key>NSMicrophoneUsageDescription</key>
   <string>Ứng dụng cần quyền ghi âm để tạo flashcard</string>
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>Ứng dụng cần quyền chuyển giọng nói thành văn bản</string>

2. Minimum iOS version: 12.0 (in ios/Podfile):
   platform :ios, '12.0'

3. App icon: Use flutter_launcher_icons to generate

4. Build command:
   flutter build ios --release
   (Note: Requires macOS and Xcode)
```

---

## 📚 LOCALIZATION - Ví dụ Cụ thể

Prompt đề cập l10n nhưng không có ví dụ:

```markdown
LOCALIZATION FILES:

lib/l10n/intl_en.arb:
{
  "@@locale": "en",
  "appTitle": "Voice Flashcards",
  "recordButton": "Record",
  "stopButton": "Stop",
  "saveButton": "Save",
  "cancelButton": "Cancel",
  "deleteButton": "Delete",
  "editButton": "Edit",
  "studyButton": "Study",
  "settingsButton": "Settings",
  "emptyStateTitle": "No flashcards yet!",
  "emptyStateSubtitle": "Tap the button below to create your first one",
  "permissionDeniedTitle": "Permission Required",
  "permissionDeniedMessage": "Please grant microphone permission to record audio"
}

lib/l10n/intl_vi.arb:
{
  "@@locale": "vi",
  "appTitle": "Flashcard Giọng Nói",
  "recordButton": "Ghi âm",
  "stopButton": "Dừng",
  "saveButton": "Lưu",
  "cancelButton": "Hủy",
  "deleteButton": "Xóa",
  "editButton": "Sửa",
  "studyButton": "Học",
  "settingsButton": "Cài đặt",
  "emptyStateTitle": "Chưa có flashcard nào!",
  "emptyStateSubtitle": "Nhấn nút bên dưới để tạo flashcard đầu tiên",
  "permissionDeniedTitle": "Cần Quyền Truy Cập",
  "permissionDeniedMessage": "Vui lòng cấp quyền ghi âm để sử dụng tính năng này"
}

Configure in pubspec.yaml:
flutter:
  generate: true

Create l10n.yaml:
arb-dir: lib/l10n
template-arb-file: intl_en.arb
output-localization-file: app_localizations.dart
```

---

## 🎨 ASSETS - Chi tiết hơn

```markdown
ASSETS STRUCTURE & PLACEHOLDERS:

assets/images/
├── panda_placeholder.png (512x512, transparent PNG)
├── panda_happy.png (reaction for correct answer)
├── panda_sad.png (reaction for wrong answer)
├── panda_wave.png (onboarding slide 1)
├── panda_mic.png (onboarding slide 2)
├── panda_books.png (onboarding slide 3)
├── app_logo.png (1024x1024 for launcher icon)

OR use SVG (smaller size):
assets/images/
├── panda_placeholder.svg
├── panda_happy.svg
├── panda_sad.svg

flutter_launcher_icons config in pubspec.yaml:
flutter_icons:
  android: true
  ios: true
  image_path: "assets/images/app_logo.png"
  adaptive_icon_background: "#A8D5BA"
  adaptive_icon_foreground: "assets/images/app_logo.png"

Generate: flutter pub run flutter_launcher_icons
```

---

## 🔄 CI/CD & VERSION MANAGEMENT (Bonus)

```markdown
VERSION MANAGEMENT (Future enhancement):

Create version.dart:
class AppVersion {
  static const String version = '1.0.0-beta';
  static const int buildNumber = 1;
  static const String buildDate = '2025-12-10';
}

Update on each release:
- Increment versionCode in build.gradle
- Update versionName
- Update CHANGELOG.md
- Tag git commit: git tag v1.0.0-beta
```

---

## ✨ PROMPT ĐÃ ĐIỀU CHỈNH - PHIÊN BẢN HOÀN THIỆN

Dưới đây là prompt đã được bổ sung tất cả các điểm trên:

---

# PROMPT HOÀN CHỈNH - FLUTTER VOICE FLASHCARD APP

You are Cursor, a code-generating AI agent. Task: generate a complete Flutter app project named `voice_note_flashcards` that implements a child-friendly (5+), education-focused voice-note → flashcard app with a Panda + matcha-green theme. The project must be production-ready (code, assets placeholders, config) and follow SOLID and Clean Architecture principles. Output must be file-by-file (path + full file content) so it can be saved to disk and built. Include instructions & Gradle config for keystore and `flutter build appbundle --release` with `compileSdk = 35` and Android settings matching below.

---

## 1) TECH STACK & ENV

- Flutter latest stable (ensure null-safety). Use Dart 3 style.
- Target Android SDK 35 (`compileSdkVersion 35`, `targetSdkVersion 35`), `minSdkVersion 23`.
- iOS minimum version: 12.0
- Use `shared_preferences` package for storage.
- Use `provider` for state management (be consistent).
- Use `just_audio` for audio playback.
- Use `record` for recording audio.
- Use `flutter_localizations` and include support for Vietnamese/English text resources.
- Use `flutter_launcher_icons` for icons (include placeholder config).
- Use `permission_handler` for runtime permissions.
- Use `file_picker` for backup import.
- Use `logger` for development logging.
- Use `equatable` for value equality in entities.
- **Optional:** Use `speech_to_text` for STT (implement basic version, fallback to manual input if unavailable).
- Follow SOLID + repository + usecase + presentation layers (Clean Architecture).

---

## 2) APP METADATA (mandatory)

- **ApplicationId:** `com.example.voice_note_flashcards`
- **versionCode:** 1
- **versionName:** "1.0.0-beta"
- **compileSdk:** 35, **minSdk:** 23, **targetSdk:** 35
- **App Name:** "Voice Flashcards" (EN) / "Flashcard Giọng Nói" (VI)
- **Build command in README:** `flutter build appbundle --release`

---

## 3) THEME & DESIGN SYSTEM

**Primary colors:**
```dart
MATCHA_LIGHT = Color(0xFFA8D5BA)
MATCHA_DEEP = Color(0xFF6BBF59)
MILK_WHITE = Color(0xFFF9FDF7)
PANDA_BLACK = Color(0xFF2E2E2E)
```

- **Font:** Poppins (include pubspec entry with `google_fonts` or manual assets).
- Large rounded corners (24–32 px), big touch targets (minimum 48x48 dp) for 5+ age group.
- Include simple panda PNG placeholders in `assets/images/` (512x512 transparent PNGs).
- **Dark mode support:** Toggle stored in `SharedPreferences` key `app_theme` = "light" | "dark".
- **Semantic labels** for all interactive widgets (screen reader support).
- **High contrast mode** compatible.

---

## 4) REQUIRED SCREENS / PAGES (implement fully)

Implement each screen as a separate widget file with clear naming and tests where applicable.

### 4.1) Splash / Onboarding (3 slides)
- Shows Panda illustrations + short instructions
- Stores `hasSeenOnboarding` boolean in SharedPreferences
- **Slide content:**
  - **Slide 1:**
    - Title: "Chào bạn! 🐼" (VI) / "Hello! 🐼" (EN)
    - Subtitle: "Ghi âm và học với flashcard vui vẻ" / "Record and learn with fun flashcards"
    - Image: `panda_wave.png`
  - **Slide 2:**
    - Title: "Ghi âm dễ dàng 🎤" / "Easy Recording 🎤"
    - Subtitle: "Nhấn nút đỏ để ghi lại giọng nói của bạn" / "Tap the red button to record your voice"
    - Image: `panda_mic.png`
  - **Slide 3:**
    - Title: "Ôn tập thông minh 📚" / "Smart Review 📚"
    - Subtitle: "Ứng dụng sẽ nhắc bạn ôn đúng lúc" / "The app will remind you to review at the right time"
    - Image: `panda_books.png`
    - CTA Button: "Bắt đầu thôi!" / "Let's Start!"

### 4.2) Home (Notes list)
- List of flashcards in a scrollable ListView
- Each card shows: title, short transcript (max 50 chars), thumbnail panda icon, `createdAt` formatted
- Floating large circular **Record button** centered bottom (56x56 dp minimum)
- Pull-to-refresh
- Search bar (filter by title/transcript)
- Sort options: Recent, Title A-Z, Due Review First
- Empty state: Show `PandaEmptyState` widget with CTA

### 4.3) Record Screen
- Large circular record button (center, 80x80 dp)
- Audio waveform animation (simple animated bars)
- **Recording flow:**
  1. Request microphone permission (first time)
  2. Show recording duration timer (MM:SS)
  3. Stop button appears while recording
  4. Max duration: 60 seconds (auto-stop with toast)
  5. Min duration: 1 second (show error if too short)
- **After recording:**
  - Show playback controls to review audio
  - **Optional STT:** Display transcribed text (or show "Transcription unavailable - enter manually")
  - Edit title (TextField, 1-100 chars, required)
  - Edit transcript (TextField, 1-500 chars, required)
  - Save/Cancel buttons
- **Save:** Calls `CreateFlashcardUsecase`, saves audio to `getApplicationDocumentsDirectory()/audio/{uuid}.m4a`

### 4.4) Flashcard Detail
- Display full text transcript
- Play audio button with progress slider
- Edit button (navigate to edit screen)
- Delete button (confirmation dialog)
- Favorite toggle (star icon)
- Show spaced repetition metadata:
  - Repeat level badge (0-5+)
  - Next review date (if set)
  - Progress bar (visual representation of mastery)
- **Panda reaction:** Show happy panda if high repeat level

### 4.5) Study Mode
Two sub-modes accessible from tab bar or segmented control:

#### A) Flip Card View
- Show flashcard with front (title) and back (full transcript)
- Tap to flip with animation (3D flip or fade)
- Audio auto-plays on flip to back
- Swipe left/right to navigate between due cards
- Bottom buttons: "Again" (reset level), "Good" (increase level)
- Update `lastReviewedAt`, `repeatLevel`, `nextReviewAt` on button press

#### B) Audio Quiz
- Filter: Show only due cards (`nextReviewAt <= now OR nextReviewAt == null`)
- **Flow:**
  1. Auto-play current flashcard audio
  2. Show 3 multiple choice options (1 correct + 2 random wrong from other flashcards)
  3. User selects one option
  4. Show immediate feedback:
     - Correct: Green highlight, `panda_happy.png`, "Chính xác!" toast, repeatLevel++
     - Wrong: Red highlight, `panda_sad.png`, "Chưa đúng, thử lại nhé!", repeatLevel = max(0, level-1)
  5. Next button to proceed to next card
- **Edge case:** If <3 flashcards exist, show message "Cần ít nhất 3 flashcard để chơi quiz" and disable quiz mode

#### Spaced Repetition Algorithm
```
repeatLevel intervals:
- Level 0: Review immediately (new card)
- Level 1: +1 day
- Level 2: +3 days
- Level 3: +7 days
- Level 4: +14 days
- Level 5+: +30 days

Update logic:
- Correct answer: repeatLevel++, nextReviewAt = now + interval
- Wrong answer: repeatLevel = max(0, repeatLevel - 1), nextReviewAt = now + interval[new level]
- "Again" button: repeatLevel = 0, nextReviewAt = now

Filtering:
- getDueFlashcards(): where (nextReviewAt <= now OR nextReviewAt == null)
```

### 4.6) Settings
- **Theme toggle:** Light/Dark mode switch (persist to SharedPreferences)
- **Language selector:** EN/VI (restart app to apply)
- **Backup section:**
  - **Export:** Button to export all flashcards to JSON file (`Downloads/voice_flashcards_backup_{timestamp}.json`)
    - Format: `{ "version": "1.0.0", "exportedAt": "ISO8601", "flashcards": [...], "settings": {...} }`
    - Show success SnackBar with file path
  - **Import:** Button to pick JSON file and restore
    - Validate JSON structure
    - Confirmation dialog: "Thao tác này sẽ thay thế toàn bộ dữ liệu hiện tại. Tiếp tục?"
    - Merge strategy: Replace (v1, no merge option)
- **Clear all data:** Button with double confirmation
- **Permissions info:** Show current microphone permission status, button to open app settings
- **App info:** Version, build number, credits
- **Keystore info note:** "For developers: See README for signing config"

---

## 5) DATA MODEL & SHARED PREFERENCES (exact schema)

Use `SharedPreferences` storing a JSON array under key `flashcards_v1`. Example JSON item:

```json
{
  "id": "uuid-v4",
  "title": "Apple",
  "transcript": "Apple is a fruit",
  "audioPath": "audio/uuid-v4.m4a",
  "createdAt": "2025-12-10T14:30:00Z",
  "lastReviewedAt": null,
  "repeatLevel": 0,
  "nextReviewAt": null,
  "favorite": false
}
```

**Also store:**
- `app_theme` = "light" | "dark"
- `hasSeenOnboarding` = bool
- `app_language` = "en" | "vi"
- `version_code` = int (update on upgrades for migration)

**Validation rules:**
- Title: 1-100 characters, required
- Transcript: 1-500 characters, required
- Audio file: must exist and be <10MB
- Duplicate title: warn but allow

Implement a `LocalStorageRepository` (in `data/repositories/`) that serializes/deserializes model objects and exposes CRUD methods:
```dart
abstract class StorageRepository {
  Future<List<Flashcard>> getAllFlashcards();
  Future<Flashcard> getFlashcardById(String id);
  Future<void> saveFlashcard(Flashcard flashcard);
  Future<void> updateFlashcard(Flashcard flashcard);
  Future<void> deleteFlashcard(String id);
  Future<List<Flashcard>> getDueFlashcards();
}
```

---

## 6) ARCHITECTURE & SOLID RULES

### Layer separation:
- **`domain/`** — entities, repositories (interfaces), usecases
  - `entities/flashcard.dart` (pure Dart class, no Flutter dependencies)
  - `repositories/storage_repository.dart` (abstract class)
  - `usecases/create_flashcard.dart`, `get_flashcards.dart`, `update_flashcard.dart`, `delete_flashcard.dart`, `get_due_flashcards.dart`
- **`data/`** — implementations: SharedPreferences repository, audio file manager
  - `models/flashcard_model.dart` (extends entity, adds `fromJson`/`toJson`)
  - `repositories/shared_prefs_repository.dart` (implements `StorageRepository`)
  - `services/audio_service.dart` (manages recording/playback with `just_audio`/`record`)
- **`presentation/`** — providers/controllers, pages, widgets
  - `providers/flashcard_provider.dart` (ChangeNotifier with Provider)
  - `providers/theme_provider.dart`
  - `pages/` (6 pages as described above)
  - `widgets/` (reusable components)
- **`core/`** — theme, constants, utils
  - `constants.dart` (colors, strings, keys)
  - `theme.dart` (ThemeData light/dark)
  - `utils.dart` (date formatting, validators)
  - `logger.dart` (Logger instance for development)
  - `permissions_service.dart` (permission_handler wrapper)

**SOLID principles:**
- Single Responsibility: Each class has one reason to change
- Open/Closed: Use abstractions (repositories as interfaces)
- Liskov Substitution: Derived classes (models) can replace base (entities)
- Interface Segregation: Repository interfaces are focused
- Dependency Inversion: Usecases depend on repository abstractions, not implementations

**Dependency Injection:**
- Use constructors to inject dependencies (no global singletons except logger)
- Example: `CreateFlashcardUsecase(StorageRepository repository)`
- Provide dependencies in `main.dart` using `MultiProvider`

**Error Handling:**
- Implement `Result<T>` or `Either<Failure, T>` pattern in domain layer
- Common errors:
  - `StorageException` (SharedPreferences failures)
  - `AudioException` (recording/playback failures)
  - `PermissionDeniedException`
  - `ValidationException`
- User-facing:
  - SnackBar for transient errors
  - Dialog for critical errors
  - Panda sad illustration for error states
  - Localized error messages

---

## 7) FOLDER STRUCTURE (exact)

Generate the project with this folder structure (show files to create):

```
voice_note_flashcards/
├─ android/
│  ├─ app/
│  │  ├─ src/main/AndroidManifest.xml (add permissions)
│  │  ├─ build.gradle (set SDK 35, signing config)
│  │  └─ proguard-rules.pro (create)
│  └─ ...
├─ ios/
│  ├─ Runner/
│  │  ├─ Info.plist (add permissions)
│  │  └─ ...
│  └─ Podfile (set iOS 12.0)
├─ lib/
│  ├─ main.dart
│  ├─ core/
│  │  ├─ constants.dart
│  │  ├─ theme.dart
│  │  ├─ utils.dart
│  │  ├─ logger.dart
│  │  └─ permissions_service.dart
│  ├─ domain/
│  │  ├─ entities/
│  │  │  └─ flashcard.dart
│  │  ├─ repositories/
│  │  │  └─ storage_repository.dart
│  │  └─ usecases/
│  │     ├─ create_flashcard.dart
│  │     ├─ get_flashcards.dart
│  │     ├─ update_flashcard.dart
│  │     ├─ delete_flashcard.dart
│  │     └─ get_due_flashcards.dart
│  ├─ data/
│  │  ├─ models/
│  │  │  └─ flashcard_model.dart
│  │  ├─ repositories/
│  │  │  └─ shared_prefs_repository.dart
│  │  └─ services/
│  │     └─ audio_service.dart
│  ├─ presentation/
│  │  ├─ pages/
│  │  │  ├─ splash_page.dart
│  │  │  ├─ onboarding_page.dart
│  │  │  ├─ home_page.dart
│  │  │  ├─ record_page.dart
│  │  │  ├─ detail_page.dart
│  │  │  ├─ study_page.dart (with flip card & quiz sub-views)
│  │  │  └─ settings_page.dart
│  │  ├─ widgets/
│  │  │  ├─ panda_empty_state.dart
│  │  │  ├─ flashcard_tile.dart
│  │  │  ├─ large_record_button.dart
│  │  │  ├─ audio_player_widget.dart
│  │  │  ├─ flip_card_widget.dart
│  │  │  └─ rounded_card.dart
│  │  └─ providers/
│  │     ├─ flashcard_provider.dart
│  │     └─ theme_provider.dart
│  └─ l10n/
│     ├─ intl_en.arb
│     └─ intl_vi.arb
├─ test/
│  ├─ domain/
│  │  └─ usecases/
│  │     └─ create_flashcard_test.dart
│  ├─ data/
│  │  └─ repositories/
│  │     └─ shared_prefs_repository_test.dart
│  └─ presentation/
│     └─ widgets/
│        └─ flashcard_tile_test.dart
├─ assets/
│  ├─ images/
│  │  ├─ panda_placeholder.png
│  │  ├─ panda_happy.png
│  │  ├─ panda_sad.png
│  │  ├─ panda_wave.png
│  │  ├─ panda_mic.png
│  │  ├─ panda_books.png
│  │  └─ app_logo.png (1024x1024 for launcher icon)
│  └─ audio/
│     └─ .gitkeep (empty folder for runtime audio files)
├─ pubspec.yaml
├─ l10n.yaml
├─ README.md
├─ CHANGELOG.md
├─ key.properties.template (rename to key.properties and fill)
└─ .gitignore (include key.properties, key.jks)
```

---

## 8) UI DETAILS & ASSETS

### Reusable Widgets (provide full implementations):
- **`RoundedCard`:** Container with 24px rounded corners, shadow, padding
- **`LargeRecordButton`:** 80x80 dp circular button, red background (MATCHA_DEEP when not recording, red when recording), mic icon, ripple effect
- **`AudioPlayerWidget`:** Play/pause button + slider + duration text (MM:SS / MM:SS)
- **`FlipCardWidget`:** Animated container that flips 180° on tap, shows front/back content
- **`PandaEmptyState`:** Column with panda image, title text, subtitle, optional CTA button

### Color Constants (in `core/constants.dart`):
```dart
const Color matchaLight = Color(0xFFA8D5BA);
const Color matchaDeep = Color(0xFF6BBF59);
const Color milkWhite = Color(0xFFF9FDF7);
const Color pandaBlack = Color(0xFF2E2E2E);
```

### ThemeData (in `core/theme.dart`):
- Provide `lightTheme` and `darkTheme` as `ThemeData` objects
- Use `matchaDeep` as primaryColor
- Use `Poppins` as fontFamily
- Set `buttonTheme` with large minWidth (48dp)
- Set `elevatedButtonTheme` with rounded corners (24px)

### Assets:
- Provide **placeholder PNG files** (512x512 transparent) for:
  - `panda_placeholder.png`, `panda_happy.png`, `panda_sad.png`, `panda_wave.png`, `panda_mic.png`, `panda_books.png`, `app_logo.png`
- Include in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
  fonts:
    - family: Poppins
      fonts:
        - asset: fonts/Poppins-Regular.ttf
        - asset: fonts/Poppins-Bold.ttf
          weight: 700
```
- **Note:** For image generation, include comment with DALL-E prompt suggestion or use placeholder service (e.g., "Replace with cute panda illustration")

---

## 9) ANDROID CONFIG (keystore + gradle)

### 9.1) Permissions (android/app/src/main/AndroidManifest.xml)
Add before `<application>`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
```

Set `android:label` inside `<application>`:
```xml
<application android:label="Voice Flashcards" ...>
```

### 9.2) Keystore config
**`key.properties.template`** (do NOT commit real keystore):
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=voice_note_alias
storeFile=../key.jks
```

**Instructions to create keystore:**
```bash
keytool -genkey -v -keystore key.jks -alias voice_note_alias -keyalg RSA -keysize 2048 -validity 10000
```
- Place `key.jks` in project root (add to `.gitignore`)
- Copy `key.properties.template` to `key.properties` and fill values

### 9.3) build.gradle (android/app/build.gradle)
```gradle
android {
    namespace 'com.example.voice_note_flashcards'
    compileSdkVersion 35

    defaultConfig {
        applicationId "com.example.voice_note_flashcards"
        minSdkVersion 23
        targetSdkVersion 35
        versionCode 1
        versionName "1.0.0-beta"
    }

    // Read keystore properties
    def keystoreProperties = new Properties()
    def keystorePropertiesFile = rootProject.file('key.properties')
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 9.4) ProGuard rules (android/app/proguard-rules.pro)
```proguard
-keep class com.example.voice_note_flashcards.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
```

---

## 10) IOS CONFIG

### 10.1) Info.plist (ios/Runner/Info.plist)
Add before `</dict>`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Ứng dụng cần quyền ghi âm để tạo flashcard</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Ứng dụng cần quyền chuyển giọng nói thành văn bản</string>
<key>CFBundleDisplayName</key>
<string>Voice Flashcards</string>
```

### 10.2) Podfile (ios/Podfile)
Set minimum iOS version:
```ruby
platform :ios, '12.0'
```

### 10.3) Build command
```bash
flutter build ios --release
```
(Note: Requires macOS and Xcode)

---

## 11) PUBSPEC.YAML (include required deps)

Provide a complete `pubspec.yaml` with:

```yaml
name: voice_note_flashcards
description: A child-friendly voice note flashcard app
publish_to: 'none'
version: 1.0.0-beta+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State management
  provider: ^6.1.1
  
  # Storage
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
  # Audio
  record: ^5.0.4
  just_audio: ^0.9.36
  
  # Permissions
  permission_handler: ^11.0.1
  
  # Utilities
  uuid: ^4.2.1
  intl: ^0.18.1
  equatable: ^2.0.5
  logger: ^2.0.2
  
  # File operations
  file_picker: ^6.1.1
  
  # UI (optional but helpful)
  flutter_svg: ^2.0.9  # if using SVG pandas
  
  # Optional: STT
  # speech_to_text: ^6.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/app_logo.png"
  adaptive_icon_background: "#A8D5BA"
  adaptive_icon_foreground: "assets/images/app_logo.png"

flutter:
  uses-material-design: true
  generate: true
  
  assets:
    - assets/images/
  
  fonts:
    - family: Poppins
      fonts:
        - asset: fonts/Poppins-Regular.ttf
        - asset: fonts/Poppins-Bold.ttf
          weight: 700
```

---

## 12) LOCALIZATION CONFIG

**`l10n.yaml`** (in project root):
```yaml
arb-dir: lib/l10n
template-arb-file: intl_en.arb
output-localization-file: app_localizations.dart
```

**`lib/l10n/intl_en.arb`:**
```json
{
  "@@locale": "en",
  "appTitle": "Voice Flashcards",
  "recordButton": "Record",
  "stopButton": "Stop",
  "saveButton": "Save",
  "cancelButton": "Cancel",
  "deleteButton": "Delete",
  "editButton": "Edit",
  "studyButton": "Study",
  "settingsButton": "Settings",
  "emptyStateTitle": "No flashcards yet!",
  "emptyStateSubtitle": "Tap the button below to create your first one",
  "permissionDeniedTitle": "Permission Required",
  "permissionDeniedMessage": "Please grant microphone permission to record audio",
  "onboardingSlide1Title": "Hello! 🐼",
  "onboardingSlide1Subtitle": "Record and learn with fun flashcards",
  "onboardingSlide2Title": "Easy Recording 🎤",
  "onboardingSlide2Subtitle": "Tap the red button to record your voice",
  "onboardingSlide3Title": "Smart Review 📚",
  "onboardingSlide3Subtitle": "The app will remind you to review at the right time",
  "getStartedButton": "Let's Start!",
  "correctAnswerToast": "Correct!",
  "wrongAnswerToast": "Not quite, try again!",
  "quizMinCardsWarning": "You need at least 3 flashcards to play quiz",
  "exportSuccessMessage": "Backup exported to: {path}",
  "@exportSuccessMessage": {
    "placeholders": {
      "path": {
        "type": "String"
      }
    }
  },
  "importConfirmTitle": "Import Backup",
  "importConfirmMessage": "This will replace all current data. Continue?",
  "clearDataConfirmTitle": "Clear All Data",
  "clearDataConfirmMessage": "Are you sure? This cannot be undone."
}
```

**`lib/l10n/intl_vi.arb`:**
```json
{
  "@@locale": "vi",
  "appTitle": "Flashcard Giọng Nói",
  "recordButton": "Ghi âm",
  "stopButton": "Dừng",
  "saveButton": "Lưu",
  "cancelButton": "Hủy",
  "deleteButton": "Xóa",
  "editButton": "Sửa",
  "studyButton": "Học",
  "settingsButton": "Cài đặt",
  "emptyStateTitle": "Chưa có flashcard nào!",
  "emptyStateSubtitle": "Nhấn nút bên dưới để tạo flashcard đầu tiên",
  "permissionDeniedTitle": "Cần Quyền Truy Cập",
  "permissionDeniedMessage": "Vui lòng cấp quyền ghi âm để sử dụng tính năng này",
  "onboardingSlide1Title": "Chào bạn! 🐼",
  "onboardingSlide1Subtitle": "Ghi âm và học với flashcard vui vẻ",
  "onboardingSlide2Title": "Ghi âm dễ dàng 🎤",
  "onboardingSlide2Subtitle": "Nhấn nút đỏ để ghi lại giọng nói của bạn",
  "onboardingSlide3Title": "Ôn tập thông minh 📚",
  "onboardingSlide3Subtitle": "Ứng dụng sẽ nhắc bạn ôn đúng lúc",
  "getStartedButton": "Bắt đầu thôi!",
  "correctAnswerToast": "Chính xác!",
  "wrongAnswerToast": "Chưa đúng, thử lại nhé!",
  "quizMinCardsWarning": "Cần ít nhất 3 flashcard để chơi quiz",
  "exportSuccessMessage": "Đã xuất backup vào: {path}",
  "importConfirmTitle": "Nhập Backup",
  "importConfirmMessage": "Thao tác này sẽ thay thế toàn bộ dữ liệu hiện tại. Tiếp tục?",
  "clearDataConfirmTitle": "Xóa Toàn Bộ Dữ Liệu",
  "clearDataConfirmMessage": "Bạn có chắc chắn? Thao tác này không thể hoàn tác."
}
```

**In `main.dart`:**
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en'),
    Locale('vi'),
  ],
  // ...
)
```

---

## 13) BUILD & RELEASE STEPS (README)

Provide a detailed **README.md** with:

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / Xcode
- Java JDK 11+

### Setup
```bash
# 1. Get dependencies
flutter pub get

# 2. Generate launcher icons
flutter pub run flutter_launcher_icons

# 3. Create keystore (Android)
keytool -genkey -v -keystore key.jks -alias voice_note_alias -keyalg RSA -keysize 2048 -validity 10000

# 4. Copy and fill key.properties
cp key.properties.template key.properties
# Edit key.properties with your keystore credentials

# 5. Run on device/emulator
flutter run
```

### Build Release
```bash
# Android AAB
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab

# Android APK (for testing)
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release
```

### Upload to Play Console
1. Go to [Google Play Console](https://play.google.com/console)
2. Create app with `com.example.voice_note_flashcards`
3. Upload `app-release.aab` in Production track
4. Fill store listing, content rating, pricing
5. Submit for review

---

## 14) TESTS

Provide at least:

### Unit Test: `test/domain/usecases/create_flashcard_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_note_flashcards/domain/entities/flashcard.dart';
import 'package:voice_note_flashcards/domain/usecases/create_flashcard.dart';
// ... mock repository

void main() {
  group('CreateFlashcardUsecase', () {
    test('should save flashcard with correct data', () async {
      // Arrange
      final mockRepo = MockStorageRepository();
      final usecase = CreateFlashcardUsecase(mockRepo);
      final flashcard = Flashcard(
        id: 'test-id',
        title: 'Test',
        transcript: 'Test transcript',
        audioPath: 'audio/test.m4a',
        createdAt: DateTime.now(),
      );

      // Act
      await usecase.execute(flashcard);

      // Assert
      verify(mockRepo.saveFlashcard(flashcard)).called(1);
    });
  });
}
```

### Unit Test: `test/data/repositories/shared_prefs_repository_test.dart`
- Test CRUD operations
- Test JSON serialization/deserialization
- Test empty list handling

### Widget Test: `test/presentation/widgets/flashcard_tile_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:voice_note_flashcards/presentation/widgets/flashcard_tile.dart';
import 'package:voice_note_flashcards/domain/entities/flashcard.dart';

void main() {
  testWidgets('FlashcardTile displays title and play button', (tester) async {
    // Arrange
    final flashcard = Flashcard(
      id: '1',
      title: 'Apple',
      transcript: 'Apple is a fruit',
      audioPath: 'audio/test.m4a',
      createdAt: DateTime.now(),
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlashcardTile(flashcard: flashcard, onTap: () {}),
        ),
      ),
    );

    // Assert
    expect(find.text('Apple'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
```

### Integration Test (optional but nice):
- `integration_test/app_test.dart`: Full flow from onboarding → record → save → study

---

## 15) ACCESSIBILITY & CHILD-FRIENDLY RULES

- **Touch targets:** Minimum 48x48 dp for all interactive elements
- **Semantic labels:** Add `Semantics` widget or `semanticsLabel` to all IconButtons, Images
- **High contrast:** Ensure text meets WCAG AA (4.5:1 ratio) against background
- **No flashing animations:** Keep animation durations >3s, no strobe effects
- **Gentle feedback:** Panda reactions are always positive/encouraging (no "wrong" shaming, just "try again")
- **Font scaling:** Support system font scaling up to 2x (test with `textScaleFactor`)
- **Screen reader:** Test with TalkBack (Android) and VoiceOver (iOS)

---

## 16) OUTPUT FORMAT FOR CURSOR

When you generate, output the full project file list and full content of each file using this pattern (so I can copy/save):

```
=== FILE: pubspec.yaml ===
<file content here>
=== END FILE ===

=== FILE: lib/main.dart ===
<file content here>
=== END FILE ===

...etc...
```

**Also include:**
- `README.md` with build instructions and feature list
- `CHANGELOG.md` with version 1.0.0-beta notes
- `key.properties.template`
- `.gitignore` entries for `key.properties`, `key.jks`, `*.iml`, `.idea/`, `build/`
- Comments for asset placeholders (e.g., "Replace panda_placeholder.png with 512x512 PNG of cute panda")

---

## 17) ACCEPTANCE CRITERIA (what I will check)

- ✅ Project compiles: `flutter analyze` returns no critical errors
- ✅ Dependencies install: `flutter pub get` works without conflicts
- ✅ Pages implemented: Onboarding, Home, Record, Detail, Study (Flip + Quiz), Settings
- ✅ SharedPreferences: Saving/loading flashcards works and persists across app restarts
- ✅ Audio recording/playback: Functional with proper permissions
- ✅ Spaced repetition: Due cards filter correctly, levels update on quiz answers
- ✅ Theme toggle: Light/dark mode switches and persists
- ✅ Localization: EN/VI strings display correctly based on device/settings
- ✅ Android config: compileSdk 35, signing config provided (even if keystore is placeholder)
- ✅ README: Contains exact build commands to produce `app-release.aab`
- ✅ Tests: At least 3 tests pass (`flutter test`)
- ✅ Assets: Placeholder images referenced in code (even if low-quality placeholders)

---

## 18) EXTRA HELPFUL NOTES FOR IMPLEMENTATION

- Use `uuid` package with `Uuid().v4()` for id generation
- Save audio files to `${getApplicationDocumentsDirectory().path}/audio/{uuid}.m4a`
- Keep audio formats cross-platform-friendly (m4a or wav, avoid proprietary formats)
- Put string resources in `lib/l10n/` and generate `AppLocalizations` via `flutter gen-l10n`
- Keep code modular: show dependency injection via constructors (no global singletons except `Logger` instance in `core/logger.dart`)
- Use `ChangeNotifierProvider` for `FlashcardProvider` and `ThemeProvider` in `main.dart`
- Implement `PermissionsService` in `core/` that wraps `permission_handler` for testability
- For empty audio folder, include `.gitkeep` file so Git tracks the folder
- Add comprehensive comments in complex logic (spaced repetition algorithm, quiz generation)
- For Panda images: Include comment with suggested image description (e.g., "Cute panda waving, 512x512 PNG with transparent background, child-friendly art style")

---

## 19) CHANGELOG.md Template

```markdown
# Changelog

## [1.0.0-beta] - 2025-12-10

### Added
- Initial release with core flashcard features
- Voice recording with audio playback
- Spaced repetition study system
- Audio quiz mode
- Flip card study mode
- Light/dark theme support
- English/Vietnamese localization
- Backup export/import functionality
- Onboarding experience
- Child-friendly Panda theme (matcha green colors)

### Known Issues
- STT (Speech-to-Text) is placeholder only in this beta
- Audio backup not included in export (only JSON metadata)
- iOS build not tested (Android-first release)

### Coming Soon (v1.1.0)
- Cloud sync
- Image attachments for flashcards
- More quiz types
- Statistics/progress tracking
```

---

## 20) PERFORMANCE & LIMITS

- **Flashcard limit:** Warn user at 900 cards, hard limit at 1000 (show toast: "Maximum 1000 flashcards reached")
- **Audio compression:** If recording >5MB, show warning (not implemented in v1 beta, future feature)
- **Pagination:** HomePage should load first 50 cards, implement lazy loading on scroll for >50
- **Search debounce:** 300ms delay on search TextField to avoid excessive filtering
- **Audio file cleanup:** When deleting flashcard, also delete audio file from disk

---

## 21) VERSION MANAGEMENT (Optional but Professional)

Create `lib/core/version.dart`:
```dart
class AppVersion {
  static const String version = '1.0.0-beta';
  static const int buildNumber = 1;
  static const String buildDate = '2025-12-10';
}
```

Display in Settings page under "App Info".

---

## 🎯 SUMMARY CHECKLIST FOR CURSOR AI

When generating, ensure:
- [ ] All 6 pages fully implemented with navigation
- [ ] Clean Architecture: domain/data/presentation separation
- [ ] SharedPreferences repository with CRUD methods
- [ ] Audio recording/playback with permissions handling
- [ ] Spaced repetition algorithm with specified intervals
- [ ] Audio quiz with 3 random options (1 correct + 2 wrong)
- [ ] Flip card with animation
- [ ] Theme toggle (light/dark) persisted
- [ ] EN/VI localization with `flutter_localizations`
- [ ] Android SDK 35 config + signing setup
- [ ] iOS permissions in Info.plist
- [ ] Launcher icons config
- [ ] README with build commands
- [ ] 3+ tests (usecase + repository + widget)
- [ ] Panda asset placeholders with descriptions
- [ ] CHANGELOG with v1.0.0-beta notes
- [ ] `.gitignore` includes `key.properties`, `key.jks`
- [ ] File-by-file output format with `=== FILE: path ===` headers

---

# END OF PROMPT

---

## 📊 PHÂN TÍCH SO SÁNH

| Khía cạnh | Prompt gốc | Prompt đã cải thiện |
|-----------|------------|---------------------|
| **Permissions** | ❌ Chỉ đề cập sơ | ✅ Chi tiết Android + iOS |
| **STT Implementation** | ⚠️ Mơ hồ ("optional placeholder") | ✅ Rõ ràng: optional package + fallback |
| **Spaced Repetition Logic** | ⚠️ Chỉ nói khoảng thời gian | ✅ Công thức update level đầy đủ |
| **Quiz Options Generation** | ❌ Không nói cách tạo | ✅ Random từ flashcards khác + edge case |
| **Backup Format** | ⚠️ Chỉ nói "JSON" | ✅ Schema cụ thể + import flow |
| **Onboarding Content** | ❌ Không có nội dung | ✅ 3 slides đầy đủ title/subtitle/image |
| **Error Handling** | ❌ Không đề cập | ✅ Result pattern + user-facing messages |
| **Validation Rules** | ❌ Không có | ✅ Title/transcript/audio validation cụ thể |
| **Localization Examples** | ❌ Không có | ✅ Đầy đủ intl_en.arb + intl_vi.arb |
| **iOS Config** | ❌ Thiếu hoàn toàn | ✅ Info.plist + Podfile + build command |
| **ProGuard Rules** | ❌ Không có | ✅ File proguard-rules.pro |
| **Performance Limits** | ❌ Không đề cập | ✅ 1000 cards limit, pagination, debounce |
| **Accessibility Details** | ⚠️ Chung chung | ✅ Cụ thể: 48dp, semantics, screen reader |
| **Testing Coverage** | ⚠️ 2 tests cơ bản | ✅ 3+ tests + integration test option |

---

## 🎉 KẾT LUẬN

**Prompt gốc:** ⭐⭐⭐⭐☆ (4/5) - Rất tốt về cấu trúc và vision, nhưng thiếu nhiều chi tiết triển khai quan trọng.

**Prompt đã cải thiện:** ⭐⭐⭐⭐⭐ (5/5) - Đầy đủ, chi tiết, ready để AI generate code production-ready.

### Các vấn đề CRITICAL đã sửa:
1. ✅ Permissions handling đầy đủ (Android + iOS)
2. ✅ Spaced repetition algorithm cụ thể
3. ✅ Quiz generation logic rõ ràng
4. ✅ STT implementation strategy
5. ✅ iOS configuration (đã thiếu hoàn toàn)

### Các cải tiến IMPORTANT:
1. ✅ Backup/import flow chi tiết
2. ✅ Onboarding content đầy đủ
3. ✅ Error handling strategy
4. ✅ Validation rules
5. ✅ Localization examples

### Bonus additions:
1. ✅ Performance considerations
2. ✅ ProGuard rules
3. ✅ Version management
4. ✅ Detailed accessibility specs
5. ✅ Integration test suggestions

---

**Khuyến nghị:** Sử dụng prompt đã cải thiện ở phần 15 để đảm bảo AI có thể generate một ứng dụng hoàn chỉnh, production-ready, không cần bổ sung thêm thông tin.

