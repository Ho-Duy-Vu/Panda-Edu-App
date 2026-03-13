# PROMPT HOÀN CHỈNH - FLUTTER VOICE FLASHCARD APP (ANDROID ONLY)
# flutter emulators --launch Medium_Phone_API_36.1                                                          
## 🎯 MỤC TIÊU
Tạo ứng dụng Flutter hoàn chỉnh, production-ready cho **Android only**, sử dụng **SharedPreferences** để lưu trữ, tuân thủ **SOLID principles**, có đầy đủ cấu hình để build **app-release.aab** và upload lên Google Play Console ngay.

---

## 1) TECH STACK & REQUIREMENTS

### Core Technology
- **Flutter:** Phiên bản stable mới nhất (null-safety, Dart 3)
- **Platform:** Android only (không cần iOS)
- **Storage:** SharedPreferences (lưu JSON)
- **State Management:** Provider
- **Audio & Speech:** 
  - `record` package để ghi âm
  - `just_audio` package để phát âm thanh
  - `speech_to_text` package để **realtime Speech-to-Text on-device**

### Required Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State & Storage
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
  # Audio & Speech
  record: ^5.0.4
  just_audio: ^0.9.36
  speech_to_text: ^6.5.1      # 🆕 Realtime STT on-device
  
  # Permissions
  permission_handler: ^11.0.1
  
  # Utilities
  uuid: ^4.2.1
  intl: ^0.18.1
  equatable: ^2.0.5
  
  # File operations
  file_picker: ^6.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  flutter_launcher_icons: ^0.13.1
  mockito: ^5.4.4              # 🆕 For mocking in tests
  build_runner: ^2.4.7         # 🆕 For generating mocks
```

### Android Configuration
- **compileSdk:** 35
- **targetSdk:** 35
- **minSdk:** 23
- **applicationId:** `com.example.voice_note_flashcards`
- **versionCode:** 1
- **versionName:** `1.0.0-beta`

---

## 2) KIẾN TRÚC & NGUYÊN TẮC SOLID

### Clean Architecture - 3 Layers

```
lib/
├── core/                    # Utilities, constants, theme
├── domain/                  # Business logic (entities, usecases)
├── data/                    # Data sources (SharedPreferences)
└── presentation/            # UI (pages, widgets, providers)
```

### SOLID Principles Implementation

#### S - Single Responsibility Principle
- Mỗi class chỉ làm một việc duy nhất
- `FlashcardRepository` chỉ quản lý CRUD flashcards
- `AudioService` chỉ xử lý audio recording/playback
- `SpeechService` chỉ xử lý Speech-to-Text recognition
- `PermissionsService` chỉ xử lý permissions

#### O - Open/Closed Principle
- Sử dụng abstract class cho repositories
- Có thể thay đổi implementation mà không sửa usecase

#### L - Liskov Substitution Principle
- `FlashcardModel` extends `Flashcard` entity
- Có thể thay thế entity bằng model bất cứ lúc nào

#### I - Interface Segregation Principle
- Repository interfaces nhỏ, tập trung
- Không ép buộc implement methods không cần

#### D - Dependency Inversion Principle
- Usecases phụ thuộc vào abstractions (interfaces)
- Inject dependencies qua constructors
- Không có global singletons (trừ logger)

### Folder Structure Chi Tiết

```
voice_note_flashcards/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   └── res/
│   │   ├── build.gradle
│   │   └── proguard-rules.pro
│   └── build.gradle
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants.dart           # Colors, keys, strings
│   │   ├── theme.dart                # Light/dark ThemeData
│   │   ├── utils.dart                # Helper functions
│   │   └── services/
│   │       ├── permissions_service.dart
│   │       ├── audio_service.dart
│   │       └── speech_service.dart       # 🆕 STT wrapper
│   ├── domain/
│   │   ├── entities/
│   │   │   └── flashcard.dart        # Pure Dart entity
│   │   ├── repositories/
│   │   │   └── flashcard_repository.dart  # Abstract class
│   │   └── usecases/
│   │       ├── create_flashcard.dart
│   │       ├── get_all_flashcards.dart
│   │       ├── get_due_flashcards.dart
│   │       ├── update_flashcard.dart
│   │       └── delete_flashcard.dart
│   ├── data/
│   │   ├── models/
│   │   │   └── flashcard_model.dart  # JSON serialization
│   │   └── repositories/
│   │       └── flashcard_repository_impl.dart  # SharedPreferences
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── flashcard_provider.dart
│   │   │   ├── theme_provider.dart
│   │   │   └── record_stt_provider.dart   # 🆕 Recording + STT state
│   │   ├── pages/
│   │   │   ├── splash_page.dart
│   │   │   ├── onboarding_page.dart
│   │   │   ├── home_page.dart
│   │   │   ├── record_page.dart
│   │   │   ├── confirm_transcript_page.dart  # 🆕 Edit transcript before save
│   │   │   ├── detail_page.dart
│   │   │   ├── study_page.dart
│   │   │   └── settings_page.dart
│   │   └── widgets/
│   │       ├── flashcard_tile.dart
│   │       ├── panda_empty_state.dart
│   │       ├── large_record_button.dart
│   │       ├── audio_player_widget.dart
│   │       ├── flip_card_widget.dart
│   │       ├── rounded_card.dart
│   │       └── live_transcript_view.dart      # 🆕 Realtime transcript display
│   └── l10n/
│       ├── intl_en.arb
│       └── intl_vi.arb
├── test/
│   ├── domain/usecases/
│   │   └── create_flashcard_test.dart
│   ├── data/repositories/
│   │   └── flashcard_repository_impl_test.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── record_stt_provider_test.dart  # 🆕 Test STT flow
│   │   ├── widgets/
│   │   │   └── flashcard_tile_test.dart
│   │   └── pages/
│   │       └── record_page_test.dart          # 🆕 Test recording UI
├── assets/
│   ├── images/
│   │   ├── app_logo.png (1024x1024)
│   │   ├── panda_placeholder.png
│   │   ├── panda_happy.png
│   │   ├── panda_sad.png
│   │   ├── panda_wave.png
│   │   ├── panda_mic.png
│   │   └── panda_books.png
│   └── fonts/
│       ├── Poppins-Regular.ttf
│       └── Poppins-Bold.ttf
├── pubspec.yaml
├── l10n.yaml
├── README.md
├── CHANGELOG.md
├── key.properties.template
└── .gitignore
```

---

## 3) DATA MODEL & SHARED PREFERENCES

### Flashcard Entity (domain/entities/flashcard.dart)

```dart
import 'package:equatable/equatable.dart';

class Flashcard extends Equatable {
  final String id;
  final String title;
  final String transcript;
  final String audioPath;
  final DateTime createdAt;
  final DateTime? lastReviewedAt;
  final int repeatLevel;        // 0-5+
  final DateTime? nextReviewAt;
  final bool favorite;

  const Flashcard({
    required this.id,
    required this.title,
    required this.transcript,
    required this.audioPath,
    required this.createdAt,
    this.lastReviewedAt,
    this.repeatLevel = 0,
    this.nextReviewAt,
    this.favorite = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        transcript,
        audioPath,
        createdAt,
        lastReviewedAt,
        repeatLevel,
        nextReviewAt,
        favorite,
      ];
}
```

### JSON Schema (SharedPreferences)

**Key:** `flashcards_v1` (JSON array string)

```json
[
  {
    "id": "uuid-v4",
    "title": "Apple",
    "transcript": "Apple is a fruit",
    "audioPath": "audio/uuid-v4.m4a",
    "createdAt": "2025-12-10T14:30:00.000Z",
    "lastReviewedAt": null,
    "repeatLevel": 0,
    "nextReviewAt": null,
    "favorite": false
  }
]
```

### Settings Keys (SharedPreferences)

```dart
// In core/constants.dart
class StorageKeys {
  static const String flashcardsKey = 'flashcards_v1';
  static const String themeKey = 'app_theme';           // "light" | "dark"
  static const String hasSeenOnboarding = 'has_seen_onboarding';  // bool
  static const String languageKey = 'app_language';     // "en" | "vi"
}
```

### Validation Rules

```dart
class FlashcardValidator {
  static const int minTitleLength = 1;
  static const int maxTitleLength = 100;
  static const int minTranscriptLength = 1;
  static const int maxTranscriptLength = 500;
  static const int maxAudioSizeMB = 10;
  static const int maxFlashcards = 1000;
  
  static String? validateTitle(String title) {
    if (title.isEmpty || title.length < minTitleLength) {
      return 'Title must be at least $minTitleLength character';
    }
    if (title.length > maxTitleLength) {
      return 'Title must be less than $maxTitleLength characters';
    }
    return null;
  }
  
  static String? validateTranscript(String transcript) {
    if (transcript.isEmpty || transcript.length < minTranscriptLength) {
      return 'Transcript must be at least $minTranscriptLength character';
    }
    if (transcript.length > maxTranscriptLength) {
      return 'Transcript must be less than $maxTranscriptLength characters';
    }
    return null;
  }
}
```

---

## 4) THEME & DESIGN SYSTEM

### Color Palette (Matcha + Panda)

```dart
// core/constants.dart
class AppColors {
  static const Color matchaLight = Color(0xFFA8D5BA);
  static const Color matchaDeep = Color(0xFF6BBF59);
  static const Color milkWhite = Color(0xFFF9FDF7);
  static const Color pandaBlack = Color(0xFF2E2E2E);
  
  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFA726);
}
```

### Typography & Sizing

```dart
class AppSizes {
  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  
  // Touch targets (child-friendly)
  static const double minTouchTarget = 48.0;
  static const double recordButtonSize = 80.0;
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
}
```

### ThemeData (core/theme.dart)

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.matchaDeep,
    scaffoldBackgroundColor: AppColors.milkWhite,
    colorScheme: ColorScheme.light(
      primary: AppColors.matchaDeep,
      secondary: AppColors.matchaLight,
      surface: Colors.white,
      background: AppColors.milkWhite,
      error: AppColors.error,
    ),
    fontFamily: 'Poppins',
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(AppSizes.minTouchTarget, AppSizes.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.matchaDeep,
    scaffoldBackgroundColor: AppColors.pandaBlack,
    colorScheme: ColorScheme.dark(
      primary: AppColors.matchaDeep,
      secondary: AppColors.matchaLight,
      surface: Color(0xFF424242),
      background: AppColors.pandaBlack,
      error: AppColors.error,
    ),
    fontFamily: 'Poppins',
    // ... same textTheme & buttonTheme
  );
}
```

---

## 5) TÍNH NĂNG CHI TIẾT - 7 SCREENS

### 5.1) Splash Page
- Hiển thị logo app + loading indicator (2 giây)
- Check `hasSeenOnboarding`:
  - `false` → Navigate to Onboarding
  - `true` → Navigate to Home

### 5.2) Onboarding Page (3 Slides)

**Slide 1:**
- Title: "Chào bạn! 🐼" (VI) / "Hello! 🐼" (EN)
- Subtitle: "Ghi âm và học với flashcard vui vẻ"
- Image: `panda_wave.png`

**Slide 2:**
- Title: "Ghi âm dễ dàng 🎤"
- Subtitle: "Nhấn nút đỏ để ghi lại giọng nói của bạn"
- Image: `panda_mic.png`

**Slide 3:**
- Title: "Ôn tập thông minh 📚"
- Subtitle: "Ứng dụng sẽ nhắc bạn ôn đúng lúc"
- Image: `panda_books.png`
- CTA Button: "Bắt đầu thôi!" → Set `hasSeenOnboarding = true`, navigate to Home

### 5.3) Home Page (Danh sách Flashcards)

**UI Components:**
- AppBar: Title + Search icon + Menu (theme toggle)
- Body: 
  - Empty state: `PandaEmptyState` widget ("Chưa có flashcard nào!")
  - List: `ListView.builder` với `FlashcardTile` widgets
- FloatingActionButton: Large circular button (80x80) center bottom
  - Icon: Microphone
  - Color: `matchaDeep`
  - onPressed: Navigate to RecordPage

**FlashcardTile Content:**
- Panda icon thumbnail (left)
- Title (bold, 1 line ellipsis)
- Transcript preview (2 lines ellipsis, grey text)
- Created date (bottom right, small text)
- Play icon button (right)
- onTap: Navigate to DetailPage

**Features:**
- Pull to refresh
- Search bar (filter by title/transcript)
- Sort dropdown: "Mới nhất", "Tên A-Z", "Cần ôn"

### 5.4) Record Page ⭐ **WITH REALTIME SPEECH-TO-TEXT**

**State Management:** Use `RecordSttProvider` (Provider pattern) để quản lý recording + STT state.

**Flow:**

#### 1. **Pre-Recording: Permission Check**
   - Check microphone permission via `PermissionsService`
   - If denied: Show educational dialog with explanation + "Open Settings" button
   - If permanently denied: Show dialog with direct link to app settings

#### 2. **Recording UI (Active State)**

**Layout:**
- **Top Section:**
  - Panda animation (bouncing/waving while recording)
  - Timer display (MM:SS format, large font 32sp)
  - Recording indicator (red pulsing dot)

- **Middle Section (Main Feature):**
  - **`LiveTranscriptView` Widget:** 
    - Shows realtime transcript from `speech_to_text`
    - Large, readable font (24sp)
    - Auto-scrolling as text grows
    - Light grey background with rounded corners
    - Placeholder text: "Listening..." (when empty)
    - Updates in realtime as speech recognition runs

- **Bottom Section:**
  - Audio waveform animation (simple animated bars)
  - Large circular **Stop Recording** button (80dp, red)
  - Small **Pause STT** button (optional: allows user to pause speech recognition temporarily while still recording audio)
  - Progress bar for max duration (60 seconds)

**Behavior:**
- **Simultaneous Actions:**
  1. **Audio Recording:** Start `record` package → save to `getApplicationDocumentsDirectory()/audio/{uuid}.m4a`
  2. **Speech Recognition:** Initialize `speech_to_text` → listen for results → update `LiveTranscriptView` in realtime
  
- **Max Duration:** 60 seconds (auto-stop + warning toast: "Đã đạt thời gian tối đa!")
- **Min Duration:** 1 second (show error if too short: "Ghi âm quá ngắn, vui lòng thử lại")

- **STT Lifecycle:**
  ```dart
  // In RecordSttProvider
  Future<void> startRecording() async {
    // 1. Check permissions
    if (!await _permissionsService.checkMicrophonePermission()) {
      final granted = await _permissionsService.requestMicrophonePermission();
      if (!granted) {
        _state = RecordingState.error;
        _errorMessage = "Permission denied";
        notifyListeners();
        return;
      }
    }

    // 2. Generate UUID and file path
    final id = Uuid().v4();
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/audio');
    if (!await audioDir.exists()) await audioDir.create(recursive: true);
    _currentAudioPath = '${audioDir.path}/$id.m4a';

    // 3. Start audio recording
    await _recorder.start(
      path: _currentAudioPath,
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      samplingRate: 44100,
    );

    // 4. Initialize Speech-to-Text (with fallback)
    _isSttAvailable = await _speechService.initialize(
      onStatus: (status) {
        if (status == 'done') {
          _state = RecordingState.transcribing;
          notifyListeners();
        }
      },
      onError: (error) {
        _sttError = error.errorMsg;
        _isSttAvailable = false;
        notifyListeners();
      },
    );

    if (_isSttAvailable) {
      // Start listening
      await _speechService.listen(
        onResult: (result) {
          _currentTranscript = result.recognizedWords;
          _confidence = result.confidence;
          notifyListeners(); // Update UI in realtime!
        },
        listenFor: Duration(minutes: 2),
        pauseFor: Duration(seconds: 5),
        localeId: 'vi_VN', // or 'en_US' based on app language
      );
    } else {
      // Fallback: Show message "STT không khả dụng, bạn có thể nhập thủ công sau"
      _currentTranscript = "";
    }

    _state = RecordingState.recording;
    _startTime = DateTime.now();
    _startTimer();
    notifyListeners();
  }
  ```

- **Pause STT Button (Optional):**
  - Allows user to temporarily stop speech recognition (e.g., when there's background noise)
  - Audio recording continues
  - Resume STT when button pressed again

#### 3. **Stop Recording → Confirm Transcript Screen**

**Trigger:** User presses Stop button OR max duration reached

**Actions:**
1. Stop audio recording: `await _recorder.stop()`
2. Stop speech recognition: `await _speechService.stop()`
3. Verify audio file exists and size > 0
4. Navigate to `ConfirmTranscriptPage` with:
   - `audioPath`: Path to recorded M4A file
   - `transcript`: Current transcript from STT (may be empty if STT failed)
   - `confidence`: STT confidence score (0.0 - 1.0)
   - `duration`: Recording duration

#### 4. **Confirm Transcript Page** (NEW)

**Purpose:** Allow user to review and edit STT transcript before saving

**Layout:**
- **Top Section:**
  - Panda icon with checkmark
  - "Xác nhận nội dung" title

- **Audio Preview:**
  - `AudioPlayerWidget`: Play/pause button + seek slider
  - Duration label (MM:SS)

- **Editable Fields:**
  - **Title TextField:**
    - Label: "Tiêu đề"
    - Hint: "Nhập tiêu đề flashcard..."
    - **Auto-populated:** First 3-5 words from transcript (if available)
    - Max length: 100 chars
    - Required
  
  - **Transcript TextField (Multiline):**
    - Label: "Nội dung"
    - Pre-filled with STT transcript
    - Large font (18sp)
    - Min lines: 3, Max lines: 10
    - Max length: 500 chars
    - Required
    - **Hint (if empty):** "Nhập nội dung flashcard thủ công..."
  
  - **Confidence Indicator (if STT used):**
    - Show only if confidence < 0.7
    - Warning icon + text: "Độ chính xác: {confidence}% - Vui lòng kiểm tra lại"
    - Color: Orange/yellow

- **Bottom Action Buttons:**
  - **Cancel Button** (grey):
    - Show confirmation: "Hủy ghi âm này?"
    - If confirmed: Delete audio file + navigate back
  
  - **Save Button** (green, large):
    - Validate title & transcript
    - If validation fails: Show inline error messages
    - If validation passes:
      1. Generate flashcard ID (UUID)
      2. Create `Flashcard` entity
      3. Call `CreateFlashcardUsecase`
      4. Show success toast: "Đã lưu flashcard!"
      5. Navigate back to Home

**Validation Logic:**
```dart
String? validateTitle(String title) {
  if (title.trim().isEmpty) return 'Vui lòng nhập tiêu đề';
  if (title.length < 1) return 'Tiêu đề quá ngắn';
  if (title.length > 100) return 'Tiêu đề tối đa 100 ký tự';
  return null;
}

String? validateTranscript(String transcript) {
  if (transcript.trim().isEmpty) return 'Vui lòng nhập nội dung';
  if (transcript.length < 1) return 'Nội dung quá ngắn';
  if (transcript.length > 500) return 'Nội dung tối đa 500 ký tự';
  return null;
}
```

#### 5. **Error Handling & Fallback**

**STT Unavailable Scenarios:**
- Device doesn't support speech recognition
- Network issues (if STT requires connectivity)
- Language pack not downloaded

**Fallback Flow:**
1. Show info banner during recording: "Nhận dạng giọng nói không khả dụng - bạn có thể nhập thủ công sau"
2. Continue audio recording normally
3. When stopped, navigate to Confirm Transcript Page with empty transcript
4. User enters transcript manually

**Permission Denied:**
- Show dialog with clear explanation:
  ```
  Title: "Cần quyền ghi âm"
  Message: "Ứng dụng cần quyền ghi âm để tạo flashcard. 
           Vui lòng cấp quyền trong Cài đặt > Ứng dụng > Voice Flashcards > Quyền."
  Buttons: [Cancel] [Open Settings]
  ```

**Audio File Save Error:**
- Show error dialog: "Không thể lưu file âm thanh. Vui lòng kiểm tra dung lượng thiết bị."
- Return to Home without saving

#### 6. **RecordSttProvider State Management**

**States (Enum):**
```dart
enum RecordingState {
  idle,           // Not recording
  recording,      // Recording audio + STT active
  paused,         // STT paused, audio still recording
  transcribing,   // Processing final transcript
  completed,      // Ready to save
  error,          // Error occurred
}
```

**Provider Properties:**
```dart
class RecordSttProvider extends ChangeNotifier {
  // Services (injected)
  final AudioRecorder _recorder;
  final SpeechService _speechService;
  final PermissionsService _permissionsService;
  final FlashcardRepository _repository;

  // State
  RecordingState _state = RecordingState.idle;
  String _currentTranscript = '';
  String? _currentAudioPath;
  double _confidence = 0.0;
  Duration _recordingDuration = Duration.zero;
  bool _isSttAvailable = false;
  String? _errorMessage;
  String? _sttError;

  // Getters
  RecordingState get state => _state;
  String get currentTranscript => _currentTranscript;
  String? get currentAudioPath => _currentAudioPath;
  double get confidence => _confidence;
  Duration get recordingDuration => _recordingDuration;
  bool get isSttAvailable => _isSttAvailable;
  String? get errorMessage => _errorMessage;

  // Constructor
  RecordSttProvider({
    required AudioRecorder recorder,
    required SpeechService speechService,
    required PermissionsService permissionsService,
    required FlashcardRepository repository,
  })  : _recorder = recorder,
        _speechService = speechService,
        _permissionsService = permissionsService,
        _repository = repository;

  // Methods
  Future<void> startRecording() async { /* see above */ }
  Future<void> stopRecording() async { /* stop both */ }
  Future<void> pauseStt() async { /* pause STT only */ }
  Future<void> resumeStt() async { /* resume STT */ }
  Future<void> discardRecording() async { /* delete audio file */ }
  
  Future<void> saveFlashcard({
    required String title,
    required String transcript,
  }) async {
    if (_currentAudioPath == null) {
      _errorMessage = 'No audio file';
      _state = RecordingState.error;
      notifyListeners();
      return;
    }

    final flashcard = Flashcard(
      id: Uuid().v4(),
      title: title,
      transcript: transcript,
      audioPath: _currentAudioPath!,
      createdAt: DateTime.now(),
    );

    await _repository.createFlashcard(flashcard);
    
    _state = RecordingState.idle;
    _currentTranscript = '';
    _currentAudioPath = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _speechService.dispose();
    super.dispose();
  }
}
```

#### 7. **UI Widgets Details**

**`LiveTranscriptView` Widget:**
```dart
class LiveTranscriptView extends StatelessWidget {
  final String transcript;
  final bool isListening;
  final double confidence;

  const LiveTranscriptView({
    required this.transcript,
    required this.isListening,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.milkWhite.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isListening ? AppColors.matchaDeep : Colors.grey.shade300,
          width: 2,
        ),
      ),
      constraints: BoxConstraints(minHeight: 120, maxHeight: 300),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isListening)
              Row(
                children: [
                  Icon(Icons.mic, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Text('Đang lắng nghe...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            SizedBox(height: 8),
            Text(
              transcript.isEmpty ? 'Listening...' : transcript,
              style: TextStyle(
                fontSize: 24,
                height: 1.5,
                color: transcript.isEmpty ? Colors.grey : AppColors.pandaBlack,
                fontStyle: transcript.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            if (confidence > 0 && confidence < 0.7)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Độ chính xác: ${(confidence * 100).toInt()}%',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

### 5.5) Detail Page

**Display:**
- AppBar: Title + Edit icon + Delete icon
- Body:
  - Panda image (happy if repeatLevel >= 3, normal otherwise)
  - Title (large, bold)
  - Full transcript (scrollable)
  - Audio player widget (play/pause, slider, duration)
  - Metadata card:
    - Created: {date}
    - Last reviewed: {date or "Chưa ôn"}
    - Mastery level: {repeatLevel} ⭐
    - Next review: {date or "Ngay bây giờ"}
  - Favorite toggle button (heart icon)

**Actions:**
- Edit: Navigate to edit screen (reuse RecordPage logic but with existing data)
- Delete: Show confirmation dialog → Delete audio file + flashcard → Navigate back
- Favorite: Toggle `favorite` field

### 5.6) Study Page (2 Modes)

**Tab Bar:** "Flip Cards" | "Audio Quiz"

#### Mode A: Flip Card View

**Logic:**
- Load due flashcards: `getDueFlashcards()` where `nextReviewAt <= now` OR `nextReviewAt == null`
- If empty: Show "Không có flashcard nào cần ôn!" + button back to Home

**UI:**
- Center card with flip animation (3D rotate on tap)
- Front: Title (large) + "Tap to flip"
- Back: Full transcript + auto-play audio
- Bottom buttons:
  - "Lại" (red): Set `repeatLevel = 0`, `nextReviewAt = now`
  - "Khó" (orange): `repeatLevel = max(0, level-1)`
  - "Dễ" (green): `repeatLevel++`
- Swipe left/right: Next/previous card
- Progress indicator: {current}/{total}

#### Mode B: Audio Quiz

**Logic:**
- Same due flashcards filter
- If < 3 flashcards total: Show message "Cần ít nhất 3 flashcard để chơi quiz"

**Flow:**
1. Auto-play current flashcard audio
2. Show 3 options (buttons):
   - 1 correct (current flashcard transcript)
   - 2 wrong (random from other flashcards)
   - Shuffle order randomly
3. User selects option:
   - **Correct:** 
     - Green highlight
     - Show `panda_happy.png`
     - Toast: "Chính xác! ✨"
     - `repeatLevel++`
   - **Wrong:**
     - Red highlight
     - Show `panda_sad.png`
     - Toast: "Chưa đúng, thử lại nhé! 💪"
     - `repeatLevel = max(0, level-1)`
4. "Tiếp tục" button → Next card
5. End of quiz: Show summary (X/Y correct) + "Hoàn thành" button

**Spaced Repetition Intervals:**
```dart
Map<int, Duration> getInterval(int level) {
  return {
    0: Duration.zero,          // Review immediately
    1: Duration(days: 1),
    2: Duration(days: 3),
    3: Duration(days: 7),
    4: Duration(days: 14),
    5: Duration(days: 30),
  }[level] ?? Duration(days: 30);
}

void updateReview(Flashcard card, bool correct) {
  final newLevel = correct 
    ? card.repeatLevel + 1 
    : max(0, card.repeatLevel - 1);
  
  final nextReview = DateTime.now().add(getInterval(newLevel));
  
  // Update flashcard with new level & nextReviewAt
}
```

### 5.7) Settings Page

**Sections:**

**1. Giao diện**
- Theme toggle: Switch (Light/Dark mode)
  - Persist to SharedPreferences `app_theme`
  - Update via `ThemeProvider`

**2. Ngôn ngữ**
- Language selector: Radio buttons (English | Tiếng Việt)
  - Persist to SharedPreferences `app_language`
  - Show dialog: "Khởi động lại ứng dụng để áp dụng"

**3. Sao lưu & Khôi phục**
- **Export Button:**
  - Create JSON file: `voice_flashcards_backup_{timestamp}.json`
  - Format:
    ```json
    {
      "version": "1.0.0-beta",
      "exportedAt": "2025-12-10T15:30:00.000Z",
      "flashcards": [...],
      "settings": {
        "theme": "light",
        "language": "vi"
      }
    }
    ```
  - Save to `Downloads/` folder
  - Show SnackBar: "Đã xuất backup vào: {path}"

- **Import Button:**
  - Open file picker (filter: .json)
  - Parse & validate JSON
  - Show confirmation dialog: "Thao tác này sẽ thay thế toàn bộ dữ liệu. Tiếp tục?"
  - If confirmed: Replace all flashcards + settings
  - Show success toast

**4. Dữ liệu**
- **Clear all data button:**
  - First confirmation: "Xóa tất cả flashcards?"
  - Second confirmation: "Bạn chắc chắn chứ? Không thể hoàn tác!"
  - If confirmed: Delete all flashcards + audio files
  - Reset to onboarding

**5. Quyền truy cập**
- Show current microphone permission status
- Button: "Mở cài đặt ứng dụng" (if permission denied)

**6. Thông tin ứng dụng**
- App name: Voice Flashcards
- Version: 1.0.0-beta (Build 1)
- Developer: [Your name]
- Note: "Keystore & signing config: See README.md"

---

## 6) PERMISSIONS HANDLING (Android)

### AndroidManifest.xml Configuration

File: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.INTERNET"/>  <!-- 🆕 For STT (if online) -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                     android:maxSdkVersion="28" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                     android:maxSdkVersion="32" />

    <application
        android:label="Voice Flashcards"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- Rest of config -->
    </application>
</manifest>
```

### PermissionsService Implementation

```dart
// core/services/permissions_service.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  Future<bool> isMicrophonePermanentlyDenied() async {
    final status = await Permission.microphone.status;
    return status.isPermanentlyDenied;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
```

### SpeechService Implementation (NEW for STT)

```dart
// core/services/speech_service.dart
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isListening => _speech.isListening;
  bool get isAvailable => _speech.isAvailable;

  /// Initialize speech recognition
  Future<bool> initialize({
    required Function(String status) onStatus,
    required Function(stt.SpeechRecognitionError error) onError,
  }) async {
    try {
      _isInitialized = await _speech.initialize(
        onStatus: onStatus,
        onError: onError,
        debugLogging: false,
      );
      return _isInitialized;
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  /// Start listening for speech input
  Future<void> listen({
    required Function(stt.SpeechRecognitionResult result) onResult,
    Duration? listenFor,
    Duration? pauseFor,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      throw Exception('Speech recognition not initialized');
    }

    await _speech.listen(
      onResult: onResult,
      listenFor: listenFor ?? Duration(seconds: 60),
      pauseFor: pauseFor ?? Duration(seconds: 3),
      partialResults: true,  // Enable realtime updates!
      localeId: localeId ?? 'en_US',
      cancelOnError: false,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Stop listening
  Future<void> stop() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Cancel listening (discards results)
  Future<void> cancel() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }

  /// Get available locales
  Future<List<stt.LocaleName>> getLocales() async {
    if (!_isInitialized) return [];
    return await _speech.locales();
  }

  /// Check if device supports speech recognition
  static Future<bool> isSupported() async {
    final speech = stt.SpeechToText();
    return await speech.initialize();
  }

  void dispose() {
    _speech.stop();
  }
}
```

### Usage in RecordPage

```dart
// presentation/pages/record_page.dart
class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late RecordSttProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<RecordSttProvider>(context, listen: false);
  }

  Future<void> _handleStartRecording() async {
    await _provider.startRecording();
    
    if (_provider.state == RecordingState.error) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.permissionDeniedTitle),
          content: Text(_provider.errorMessage ?? 'Unknown error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancelButton),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings(); // From permission_handler
              },
              child: Text(AppLocalizations.of(context)!.goToSettingsButton),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Record Flashcard')),
      body: Consumer<RecordSttProvider>(
        builder: (context, provider, child) {
          if (provider.state == RecordingState.idle) {
            return _buildIdleUI();
          } else if (provider.state == RecordingState.recording) {
            return _buildRecordingUI(provider);
          } else if (provider.state == RecordingState.completed) {
            // Navigate to Confirm Transcript Page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmTranscriptPage(
                    audioPath: provider.currentAudioPath!,
                    transcript: provider.currentTranscript,
                    confidence: provider.confidence,
                  ),
                ),
              );
            });
            return SizedBox.shrink();
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildRecordingUI(RecordSttProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Panda animation
        Image.asset('assets/images/panda_mic.png', width: 120),
        
        // Timer
        Text(
          _formatDuration(provider.recordingDuration),
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        
        // Live Transcript View
        LiveTranscriptView(
          transcript: provider.currentTranscript,
          isListening: provider.isSttAvailable,
          confidence: provider.confidence,
        ),
        
        // STT unavailable warning
        if (!provider.isSttAvailable)
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nhận dạng giọng nói không khả dụng - bạn có thể nhập thủ công sau',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        
        // Waveform animation
        _buildWaveformAnimation(),
        
        // Stop button
        LargeRecordButton(
          isRecording: true,
          onPressed: () => provider.stopRecording(),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
```

---

## 7) ANDROID CONFIGURATION & BUILD SETUP

### 7.1) Project build.gradle

File: `android/build.gradle`

```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### 7.2) App build.gradle

File: `android/app/build.gradle`

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace 'com.example.voice_note_flashcards'
    compileSdkVersion 35
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "com.example.voice_note_flashcards"
        minSdkVersion 23
        targetSdkVersion 35
        versionCode 1
        versionName "1.0.0-beta"
    }

    // Load keystore properties
    def keystorePropertiesFile = rootProject.file("key.properties")
    def keystoreProperties = new Properties()
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

flutter {
    source '../..'
}
```

### 7.3) ProGuard Rules

File: `android/app/proguard-rules.pro`

```proguard
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# App specific
-keep class com.example.voice_note_flashcards.** { *; }

# Audio plugins
-keep class com.llfbandit.record.** { *; }
-keep class com.ryanheise.just_audio.** { *; }

# 🆕 Speech to Text plugin
-keep class com.csdcorp.speech_to_text.** { *; }
```

### 7.4) Keystore Configuration

**File: `key.properties.template`**

```properties
storePassword=YOUR_STORE_PASSWORD_HERE
keyPassword=YOUR_KEY_PASSWORD_HERE
keyAlias=voice_note_alias
storeFile=../key.jks
```

**Instructions to create keystore:**

```bash
# Run this command in project root directory
keytool -genkey -v -keystore key.jks -alias voice_note_alias -keyalg RSA -keysize 2048 -validity 10000

# You will be prompted to enter:
# - Password for keystore
# - Password for key (can be same as keystore)
# - Your name/organization details
```

**Setup steps:**
1. Create keystore: Run keytool command above
2. Copy template: `cp key.properties.template key.properties`
3. Edit `key.properties` with your actual passwords
4. **IMPORTANT:** Add to `.gitignore`:
   ```
   key.properties
   key.jks
   ```

### 7.5) Launcher Icon Configuration

**In `pubspec.yaml`:**

```yaml
flutter_launcher_icons:
  android: true
  image_path: "assets/images/app_logo.png"
  adaptive_icon_background: "#A8D5BA"
  adaptive_icon_foreground: "assets/images/app_logo.png"
  min_sdk_android: 23
```

**Generate icons:**
```bash
flutter pub run flutter_launcher_icons
```

---

## 8) LOCALIZATION SETUP

### l10n.yaml

```yaml
arb-dir: lib/l10n
template-arb-file: intl_en.arb
output-localization-file: app_localizations.dart
```

### lib/l10n/intl_en.arb

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
  "homeTab": "Home",
  "emptyStateTitle": "No flashcards yet!",
  "emptyStateSubtitle": "Tap the button below to create your first one",
  "permissionDeniedTitle": "Permission Required",
  "permissionDeniedMessage": "Please grant microphone permission to record audio",
  "goToSettingsButton": "Open Settings",
  "onboardingSlide1Title": "Hello! 🐼",
  "onboardingSlide1Subtitle": "Record and learn with fun flashcards",
  "onboardingSlide2Title": "Easy Recording 🎤",
  "onboardingSlide2Subtitle": "Tap the red button to record your voice",
  "onboardingSlide3Title": "Smart Review 📚",
  "onboardingSlide3Subtitle": "The app will remind you to review at the right time",
  "getStartedButton": "Let's Start!",
  "titleLabel": "Title",
  "transcriptLabel": "Transcript",
  "titleHint": "Enter flashcard title...",
  "transcriptHint": "Enter flashcard content...",
  "recordingTitle": "Recording...",
  "recordingDuration": "{duration}",
  "@recordingDuration": {
    "placeholders": {
      "duration": {"type": "String"}
    }
  },
  "playButton": "Play",
  "pauseButton": "Pause",
  "deleteConfirmTitle": "Delete Flashcard",
  "deleteConfirmMessage": "Are you sure you want to delete this flashcard?",
  "flipCardFront": "Tap to flip",
  "flipCardBack": "Tap to see front",
  "studyAgainButton": "Again",
  "studyHardButton": "Hard",
  "studyEasyButton": "Easy",
  "correctAnswerToast": "Correct! ✨",
  "wrongAnswerToast": "Not quite, try again! 💪",
  "quizMinCardsWarning": "You need at least 3 flashcards to play quiz",
  "quizCompleteTitle": "Quiz Complete!",
  "quizCompleteMessage": "You got {correct} out of {total} correct",
  "@quizCompleteMessage": {
    "placeholders": {
      "correct": {"type": "int"},
      "total": {"type": "int"}
    }
  },
  "continueButton": "Continue",
  "finishButton": "Finish",
  "noDueCardsTitle": "No cards to review!",
  "noDueCardsSubtitle": "Come back later or create more flashcards",
  "themeSection": "Appearance",
  "languageSection": "Language",
  "backupSection": "Backup & Restore",
  "dataSection": "Data",
  "permissionsSection": "Permissions",
  "aboutSection": "About",
  "lightMode": "Light Mode",
  "darkMode": "Dark Mode",
  "exportButton": "Export Backup",
  "importButton": "Import Backup",
  "clearDataButton": "Clear All Data",
  "exportSuccessMessage": "Backup exported to: {path}",
  "@exportSuccessMessage": {
    "placeholders": {
      "path": {"type": "String"}
    }
  },
  "importConfirmTitle": "Import Backup",
  "importConfirmMessage": "This will replace all current data. Continue?",
  "clearDataConfirmTitle": "Clear All Data",
  "clearDataConfirmMessage": "Are you sure? This cannot be undone.",
  "microphonePermission": "Microphone Permission",
  "permissionGranted": "Granted",
  "permissionDenied": "Denied",
  "openAppSettingsButton": "Open App Settings",
  "appVersion": "Version",
  "buildNumber": "Build",
  "listeningLabel": "Listening...",
  "pauseSttButton": "Pause Speech Recognition",
  "resumeSttButton": "Resume Speech Recognition",
  "sttUnavailableWarning": "Speech recognition unavailable - you can type manually later",
  "confirmTranscriptTitle": "Confirm Content",
  "lowConfidenceWarning": "Accuracy: {confidence}% - Please review",
  "@lowConfidenceWarning": {
    "placeholders": {
      "confidence": {"type": "int"}
    }
  },
  "autoTitleHint": "Auto-generated from speech",
  "editTranscriptHint": "Tap to edit transcript",
  "discardRecordingConfirm": "Discard this recording?",
  "maxDurationReached": "Maximum recording duration reached!",
  "minDurationError": "Recording too short, please try again",
  "audioFileSaveError": "Cannot save audio file. Please check device storage.",
  "flashcardSavedSuccess": "Flashcard saved successfully!",
  "transcriptPlaceholder": "Start speaking to see transcript here...",
  "manualInputButton": "Type Manually"
}
```

### lib/l10n/intl_vi.arb

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
  "homeTab": "Trang chủ",
  "emptyStateTitle": "Chưa có flashcard nào!",
  "emptyStateSubtitle": "Nhấn nút bên dưới để tạo flashcard đầu tiên",
  "permissionDeniedTitle": "Cần Quyền Truy Cập",
  "permissionDeniedMessage": "Vui lòng cấp quyền ghi âm để sử dụng tính năng này",
  "goToSettingsButton": "Mở Cài đặt",
  "onboardingSlide1Title": "Chào bạn! 🐼",
  "onboardingSlide1Subtitle": "Ghi âm và học với flashcard vui vẻ",
  "onboardingSlide2Title": "Ghi âm dễ dàng 🎤",
  "onboardingSlide2Subtitle": "Nhấn nút đỏ để ghi lại giọng nói của bạn",
  "onboardingSlide3Title": "Ôn tập thông minh 📚",
  "onboardingSlide3Subtitle": "Ứng dụng sẽ nhắc bạn ôn đúng lúc",
  "getStartedButton": "Bắt đầu thôi!",
  "titleLabel": "Tiêu đề",
  "transcriptLabel": "Nội dung",
  "titleHint": "Nhập tiêu đề flashcard...",
  "transcriptHint": "Nhập nội dung flashcard...",
  "recordingTitle": "Đang ghi âm...",
  "recordingDuration": "{duration}",
  "playButton": "Phát",
  "pauseButton": "Tạm dừng",
  "deleteConfirmTitle": "Xóa Flashcard",
  "deleteConfirmMessage": "Bạn có chắc chắn muốn xóa flashcard này?",
  "flipCardFront": "Nhấn để lật",
  "flipCardBack": "Nhấn để xem mặt trước",
  "studyAgainButton": "Lại",
  "studyHardButton": "Khó",
  "studyEasyButton": "Dễ",
  "correctAnswerToast": "Chính xác! ✨",
  "wrongAnswerToast": "Chưa đúng, thử lại nhé! 💪",
  "quizMinCardsWarning": "Cần ít nhất 3 flashcard để chơi quiz",
  "quizCompleteTitle": "Hoàn thành Quiz!",
  "quizCompleteMessage": "Bạn trả lời đúng {correct}/{total} câu",
  "continueButton": "Tiếp tục",
  "finishButton": "Hoàn thành",
  "noDueCardsTitle": "Không có thẻ nào cần ôn!",
  "noDueCardsSubtitle": "Quay lại sau hoặc tạo thêm flashcard mới",
  "themeSection": "Giao diện",
  "languageSection": "Ngôn ngữ",
  "backupSection": "Sao lưu & Khôi phục",
  "dataSection": "Dữ liệu",
  "permissionsSection": "Quyền truy cập",
  "aboutSection": "Thông tin",
  "lightMode": "Sáng",
  "darkMode": "Tối",
  "exportButton": "Xuất Backup",
  "importButton": "Nhập Backup",
  "clearDataButton": "Xóa Toàn Bộ Dữ Liệu",
  "exportSuccessMessage": "Đã xuất backup vào: {path}",
  "importConfirmTitle": "Nhập Backup",
  "importConfirmMessage": "Thao tác này sẽ thay thế toàn bộ dữ liệu hiện tại. Tiếp tục?",
  "clearDataConfirmTitle": "Xóa Toàn Bộ Dữ Liệu",
  "clearDataConfirmMessage": "Bạn có chắc chắn? Thao tác này không thể hoàn tác.",
  "microphonePermission": "Quyền Ghi Âm",
  "permissionGranted": "Đã cấp",
  "permissionDenied": "Bị từ chối",
  "openAppSettingsButton": "Mở Cài đặt Ứng dụng",
  "appVersion": "Phiên bản",
  "buildNumber": "Build",
  "listeningLabel": "Đang lắng nghe...",
  "pauseSttButton": "Tạm dừng Nhận dạng",
  "resumeSttButton": "Tiếp tục Nhận dạng",
  "sttUnavailableWarning": "Nhận dạng giọng nói không khả dụng - bạn có thể nhập thủ công sau",
  "confirmTranscriptTitle": "Xác nhận Nội dung",
  "lowConfidenceWarning": "Độ chính xác: {confidence}% - Vui lòng kiểm tra lại",
  "autoTitleHint": "Tự động tạo từ giọng nói",
  "editTranscriptHint": "Nhấn để sửa nội dung",
  "discardRecordingConfirm": "Hủy ghi âm này?",
  "maxDurationReached": "Đã đạt thời gian ghi âm tối đa!",
  "minDurationError": "Ghi âm quá ngắn, vui lòng thử lại",
  "audioFileSaveError": "Không thể lưu file âm thanh. Vui lòng kiểm tra dung lượng thiết bị.",
  "flashcardSavedSuccess": "Đã lưu flashcard thành công!",
  "transcriptPlaceholder": "Bắt đầu nói để xem nội dung ở đây...",
  "manualInputButton": "Nhập Thủ công"
}
```

### main.dart Integration

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
  onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'),
    Locale('vi'),
  ],
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeProvider.themeMode,
  home: SplashPage(),
)
```

---

## 9) TESTING REQUIREMENTS

### 9.1) Unit Tests

**test/domain/usecases/create_flashcard_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:voice_note_flashcards/domain/entities/flashcard.dart';
import 'package:voice_note_flashcards/domain/repositories/flashcard_repository.dart';
import 'package:voice_note_flashcards/domain/usecases/create_flashcard.dart';

class MockFlashcardRepository extends Mock implements FlashcardRepository {}

void main() {
  late CreateFlashcardUsecase usecase;
  late MockFlashcardRepository mockRepository;

  setUp(() {
    mockRepository = MockFlashcardRepository();
    usecase = CreateFlashcardUsecase(mockRepository);
  });

  group('CreateFlashcardUsecase', () {
    test('should save flashcard via repository', () async {
      // Arrange
      final flashcard = Flashcard(
        id: 'test-id',
        title: 'Test Card',
        transcript: 'Test content',
        audioPath: 'audio/test.m4a',
        createdAt: DateTime.now(),
      );

      when(mockRepository.createFlashcard(flashcard))
          .thenAnswer((_) async => flashcard);

      // Act
      final result = await usecase.execute(flashcard);

      // Assert
      expect(result, flashcard);
      verify(mockRepository.createFlashcard(flashcard)).called(1);
    });
  });
}
```

**test/data/repositories/flashcard_repository_impl_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_note_flashcards/data/repositories/flashcard_repository_impl.dart';
import 'package:voice_note_flashcards/domain/entities/flashcard.dart';

void main() {
  late FlashcardRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = FlashcardRepositoryImpl(prefs);
  });

  group('FlashcardRepositoryImpl', () {
    test('should save and retrieve flashcards', () async {
      // Arrange
      final flashcard = Flashcard(
        id: 'test-1',
        title: 'Test',
        transcript: 'Test content',
        audioPath: 'audio/test.m4a',
        createdAt: DateTime.now(),
      );

      // Act
      await repository.createFlashcard(flashcard);
      final flashcards = await repository.getAllFlashcards();

      // Assert
      expect(flashcards.length, 1);
      expect(flashcards.first.id, 'test-1');
      expect(flashcards.first.title, 'Test');
    });

    test('should delete flashcard by id', () async {
      // Arrange
      final flashcard = Flashcard(
        id: 'test-1',
        title: 'Test',
        transcript: 'Test content',
        audioPath: 'audio/test.m4a',
        createdAt: DateTime.now(),
      );
      await repository.createFlashcard(flashcard);

      // Act
      await repository.deleteFlashcard('test-1');
      final flashcards = await repository.getAllFlashcards();

      // Assert
      expect(flashcards.isEmpty, true);
    });
  });
}
```

### 9.2) Widget Tests

**test/presentation/widgets/flashcard_tile_test.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_note_flashcards/domain/entities/flashcard.dart';
import 'package:voice_note_flashcards/presentation/widgets/flashcard_tile.dart';

void main() {
  testWidgets('FlashcardTile displays title and play button',
      (WidgetTester tester) async {
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
          body: FlashcardTile(
            flashcard: flashcard,
            onTap: () {},
            onPlay: () {},
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Apple'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.text('Apple is a fruit'), findsOneWidget);
  });

  testWidgets('FlashcardTile onTap callback works',
      (WidgetTester tester) async {
    // Arrange
    var tapped = false;
    final flashcard = Flashcard(
      id: '1',
      title: 'Test',
      transcript: 'Test content',
      audioPath: 'audio/test.m4a',
      createdAt: DateTime.now(),
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlashcardTile(
            flashcard: flashcard,
            onTap: () => tapped = true,
            onPlay: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FlashcardTile));
    await tester.pumpAndSettle();

    // Assert
    expect(tapped, true);
  });
}
```

### 9.3) 🆕 **Provider Tests for Realtime STT**

**test/presentation/providers/record_stt_provider_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:record/record.dart';
import 'package:voice_note_flashcards/core/services/speech_service.dart';
import 'package:voice_note_flashcards/core/services/permissions_service.dart';
import 'package:voice_note_flashcards/domain/repositories/flashcard_repository.dart';
import 'package:voice_note_flashcards/presentation/providers/record_stt_provider.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([
  AudioRecorder,
  SpeechService,
  PermissionsService,
  FlashcardRepository,
])
import 'record_stt_provider_test.mocks.dart';

void main() {
  late RecordSttProvider provider;
  late MockAudioRecorder mockRecorder;
  late MockSpeechService mockSpeechService;
  late MockPermissionsService mockPermissionsService;
  late MockFlashcardRepository mockRepository;

  setUp(() {
    mockRecorder = MockAudioRecorder();
    mockSpeechService = MockSpeechService();
    mockPermissionsService = MockPermissionsService();
    mockRepository = MockFlashcardRepository();

    provider = RecordSttProvider(
      recorder: mockRecorder,
      speechService: mockSpeechService,
      permissionsService: mockPermissionsService,
      repository: mockRepository,
    );
  });

  group('RecordSttProvider - STT Integration', () {
    test('startRecording initializes both audio recording and STT', () async {
      // Arrange
      when(mockPermissionsService.checkMicrophonePermission())
          .thenAnswer((_) async => true);
      when(mockRecorder.hasPermission()).thenAnswer((_) async => true);
      when(mockRecorder.start(path: anyNamed('path'), encoder: anyNamed('encoder')))
          .thenAnswer((_) async => {});
      when(mockSpeechService.initialize(
        onStatus: anyNamed('onStatus'),
        onError: anyNamed('onError'),
      )).thenAnswer((_) async => true);
      when(mockSpeechService.listen(
        onResult: anyNamed('onResult'),
        listenFor: anyNamed('listenFor'),
        pauseFor: anyNamed('pauseFor'),
        localeId: anyNamed('localeId'),
      )).thenAnswer((_) async => {});

      // Act
      await provider.startRecording();

      // Assert
      expect(provider.state, RecordingState.recording);
      verify(mockRecorder.start(
        path: anyNamed('path'),
        encoder: anyNamed('encoder'),
      )).called(1);
      verify(mockSpeechService.initialize(
        onStatus: anyNamed('onStatus'),
        onError: anyNamed('onError'),
      )).called(1);
      verify(mockSpeechService.listen(
        onResult: anyNamed('onResult'),
        listenFor: anyNamed('listenFor'),
        pauseFor: anyNamed('pauseFor'),
        localeId: anyNamed('localeId'),
      )).called(1);
    });

    test('updates transcript in realtime when STT emits results', () async {
      // Arrange
      when(mockPermissionsService.checkMicrophonePermission())
          .thenAnswer((_) async => true);
      when(mockRecorder.hasPermission()).thenAnswer((_) async => true);
      when(mockRecorder.start(path: anyNamed('path'), encoder: anyNamed('encoder')))
          .thenAnswer((_) async => {});
      
      // Capture the onResult callback
      Function? onResultCallback;
      when(mockSpeechService.initialize(
        onStatus: anyNamed('onStatus'),
        onError: anyNamed('onError'),
      )).thenAnswer((_) async => true);
      when(mockSpeechService.listen(
        onResult: anyNamed('onResult'),
        listenFor: anyNamed('listenFor'),
        pauseFor: anyNamed('pauseFor'),
        localeId: anyNamed('localeId'),
      )).thenAnswer((invocation) {
        onResultCallback = invocation.namedArguments[#onResult];
        return Future.value();
      });

      await provider.startRecording();

      // Act - Simulate STT result
      final mockResult = MockSpeechRecognitionResult();
      when(mockResult.recognizedWords).thenReturn('Hello World');
      when(mockResult.confidence).thenReturn(0.95);
      onResultCallback?.call(mockResult);

      // Assert
      expect(provider.currentTranscript, 'Hello World');
      expect(provider.confidence, 0.95);
    });

    test('gracefully handles STT unavailable and continues audio recording', () async {
      // Arrange
      when(mockPermissionsService.checkMicrophonePermission())
          .thenAnswer((_) async => true);
      when(mockRecorder.hasPermission()).thenAnswer((_) async => true);
      when(mockRecorder.start(path: anyNamed('path'), encoder: anyNamed('encoder')))
          .thenAnswer((_) async => {});
      when(mockSpeechService.initialize(
        onStatus: anyNamed('onStatus'),
        onError: anyNamed('onError'),
      )).thenAnswer((_) async => false); // STT fails to initialize

      // Act
      await provider.startRecording();

      // Assert
      expect(provider.state, RecordingState.recording);
      expect(provider.isSttAvailable, false);
      expect(provider.currentTranscript, ''); // Empty transcript
      verify(mockRecorder.start(
        path: anyNamed('path'),
        encoder: anyNamed('encoder'),
      )).called(1); // Audio still recording!
    });

    test('stopRecording stops both audio and STT', () async {
      // Arrange
      when(mockPermissionsService.checkMicrophonePermission())
          .thenAnswer((_) async => true);
      when(mockRecorder.hasPermission()).thenAnswer((_) async => true);
      when(mockRecorder.start(path: anyNamed('path'), encoder: anyNamed('encoder')))
          .thenAnswer((_) async => {});
      when(mockRecorder.stop()).thenAnswer((_) async => 'audio/test.m4a');
      when(mockSpeechService.initialize(
        onStatus: anyNamed('onStatus'),
        onError: anyNamed('onError'),
      )).thenAnswer((_) async => true);
      when(mockSpeechService.listen(
        onResult: anyNamed('onResult'),
        listenFor: anyNamed('listenFor'),
        pauseFor: anyNamed('pauseFor'),
        localeId: anyNamed('localeId'),
      )).thenAnswer((_) async => {});
      when(mockSpeechService.isListening).thenReturn(true);
      when(mockSpeechService.stop()).thenAnswer((_) async => {});

      await provider.startRecording();

      // Act
      await provider.stopRecording();

      // Assert
      expect(provider.state, RecordingState.completed);
      verify(mockRecorder.stop()).called(1);
      verify(mockSpeechService.stop()).called(1);
    });

    test('saveFlashcard creates flashcard with transcript and audio path', () async {
      // Arrange
      provider.setTestState(
        audioPath: 'audio/test-123.m4a',
        transcript: 'Test transcript from STT',
      );
      when(mockRepository.createFlashcard(any))
          .thenAnswer((_) async => {});

      // Act
      await provider.saveFlashcard(
        title: 'Test Title',
        transcript: 'Test transcript from STT',
      );

      // Assert
      final captured = verify(mockRepository.createFlashcard(captureAny))
          .captured
          .single as Flashcard;
      expect(captured.title, 'Test Title');
      expect(captured.transcript, 'Test transcript from STT');
      expect(captured.audioPath, 'audio/test-123.m4a');
      expect(provider.state, RecordingState.idle);
    });

    test('handles permission denied gracefully', () async {
      // Arrange
      when(mockPermissionsService.checkMicrophonePermission())
          .thenAnswer((_) async => false);
      when(mockPermissionsService.requestMicrophonePermission())
          .thenAnswer((_) async => false);

      // Act
      await provider.startRecording();

      // Assert
      expect(provider.state, RecordingState.error);
      expect(provider.errorMessage, isNotNull);
      verifyNever(mockRecorder.start(
        path: anyNamed('path'),
        encoder: anyNamed('encoder'),
      ));
    });
  });
}

// Helper mock class for SpeechRecognitionResult
class MockSpeechRecognitionResult {
  String recognizedWords = '';
  double confidence = 0.0;
}
```

### 9.4) 🆕 **Widget Tests for Recording UI**

**test/presentation/pages/record_page_test.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:voice_note_flashcards/presentation/pages/record_page.dart';
import 'package:voice_note_flashcards/presentation/providers/record_stt_provider.dart';
import 'package:voice_note_flashcards/presentation/widgets/live_transcript_view.dart';
import 'package:voice_note_flashcards/presentation/widgets/large_record_button.dart';

import '../providers/record_stt_provider_test.mocks.dart';

void main() {
  late MockRecordSttProvider mockProvider;

  setUp(() {
    mockProvider = MockRecordSttProvider();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<RecordSttProvider>.value(
        value: mockProvider,
        child: RecordPage(),
      ),
    );
  }

  testWidgets('displays LiveTranscriptView with realtime transcript',
      (WidgetTester tester) async {
    // Arrange
    when(mockProvider.state).thenReturn(RecordingState.recording);
    when(mockProvider.currentTranscript).thenReturn('Hello from speech recognition');
    when(mockProvider.isSttAvailable).thenReturn(true);
    when(mockProvider.confidence).thenReturn(0.9);
    when(mockProvider.recordingDuration).thenReturn(Duration(seconds: 15));

    // Act
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(LiveTranscriptView), findsOneWidget);
    expect(find.text('Hello from speech recognition'), findsOneWidget);
  });

  testWidgets('shows STT unavailable warning when STT fails',
      (WidgetTester tester) async {
    // Arrange
    when(mockProvider.state).thenReturn(RecordingState.recording);
    when(mockProvider.currentTranscript).thenReturn('');
    when(mockProvider.isSttAvailable).thenReturn(false);
    when(mockProvider.recordingDuration).thenReturn(Duration(seconds: 5));

    // Act
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Assert
    expect(
      find.text('Nhận dạng giọng nói không khả dụng - bạn có thể nhập thủ công sau'),
      findsOneWidget,
    );
  });

  testWidgets('LargeRecordButton triggers startRecording on tap',
      (WidgetTester tester) async {
    // Arrange
    when(mockProvider.state).thenReturn(RecordingState.idle);
    when(mockProvider.startRecording()).thenAnswer((_) async => {});

    // Act
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    final recordButton = find.byType(LargeRecordButton);
    expect(recordButton, findsOneWidget);
    
    await tester.tap(recordButton);
    await tester.pumpAndSettle();

    // Assert
    verify(mockProvider.startRecording()).called(1);
  });

  testWidgets('updates transcript in realtime as provider notifies',
      (WidgetTester tester) async {
    // Arrange
    when(mockProvider.state).thenReturn(RecordingState.recording);
    when(mockProvider.currentTranscript).thenReturn('Initial');
    when(mockProvider.isSttAvailable).thenReturn(true);
    when(mockProvider.confidence).thenReturn(0.8);
    when(mockProvider.recordingDuration).thenReturn(Duration(seconds: 5));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Initial'), findsOneWidget);

    // Act - Simulate provider update
    when(mockProvider.currentTranscript).thenReturn('Initial text updated');
    mockProvider.notifyListeners();
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Initial text updated'), findsOneWidget);
  });

  testWidgets('navigates to ConfirmTranscriptPage when recording completed',
      (WidgetTester tester) async {
    // Arrange
    when(mockProvider.state).thenReturn(RecordingState.idle);
    
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Act - Simulate state change to completed
    when(mockProvider.state).thenReturn(RecordingState.completed);
    when(mockProvider.currentAudioPath).thenReturn('audio/test.m4a');
    when(mockProvider.currentTranscript).thenReturn('Final transcript');
    when(mockProvider.confidence).thenReturn(0.92);
    
    mockProvider.notifyListeners();
    await tester.pumpAndSettle();

    // Assert - Should navigate to ConfirmTranscriptPage
    expect(find.byType(ConfirmTranscriptPage), findsOneWidget);
  });
}

// Mock provider for testing
class MockRecordSttProvider extends Mock implements RecordSttProvider {
  @override
  Stream<RecordingState> get stateStream => Stream.value(RecordingState.idle);
}
```

### 9.5) Test Generation Commands

**Generate mocks for testing:**

```bash
# Add build_runner to dev_dependencies first (already in pubspec.yaml)

# Generate mocks
flutter pub run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test

# Run specific test file
flutter test test/presentation/providers/record_stt_provider_test.dart

# Run with coverage
flutter test --coverage
flutter pub global activate coverage
flutter pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.packages --report-on=lib
```

---

## 10) BUILD & RELEASE INSTRUCTIONS

### Prerequisites

```bash
# Check Flutter installation
flutter doctor -v

# Required:
# ✓ Flutter SDK (stable channel)
# ✓ Android SDK (API 35)
# ✓ Android Studio / VS Code
# ✓ Java JDK 11+
```

### Setup Steps

```bash
# 1. Clone/Create project
cd voice_note_flashcards

# 2. Get dependencies
flutter pub get

# 3. Generate localization files
flutter gen-l10n

# 4. Generate launcher icons
flutter pub run flutter_launcher_icons

# 5. Create keystore (IMPORTANT!)
keytool -genkey -v -keystore key.jks -alias voice_note_alias \
  -keyalg RSA -keysize 2048 -validity 10000

# Follow prompts:
# - Enter keystore password (remember this!)
# - Enter key password (can be same)
# - Enter your name, organization, etc.

# 6. Setup key.properties
cp key.properties.template key.properties

# Edit key.properties:
# storePassword=YOUR_ACTUAL_PASSWORD
# keyPassword=YOUR_ACTUAL_PASSWORD
# keyAlias=voice_note_alias
# storeFile=../key.jks

# 7. Verify configuration
flutter analyze
```

### Development Build

```bash
# Run on connected device/emulator
flutter run

# Run with specific device
flutter devices
flutter run -d <device-id>

# Run in release mode (faster)
flutter run --release
```

### Production Build

```bash
# Clean previous builds
flutter clean
flutter pub get

# Build Android App Bundle (AAB) - for Google Play
flutter build appbundle --release

# Output file location:
# build/app/outputs/bundle/release/app-release.aab

# Optional: Build APK (for direct installation/testing)
flutter build apk --release

# Output file location:
# build/app/outputs/flutter-apk/app-release.apk

# Check file size
ls -lh build/app/outputs/bundle/release/app-release.aab
```

### 🆕 Testing Realtime STT on Device

**IMPORTANT:** Speech-to-Text works ONLY on real devices, NOT in emulators!

```bash
# 1. Enable USB debugging on Android device
# Settings > Developer Options > USB Debugging

# 2. Connect device via USB
adb devices

# 3. Run app on device
flutter run --release -d <device-id>

# 4. Test STT features:
# - Grant microphone permission when prompted
# - Tap Record button
# - Speak clearly: "Hello, this is a test flashcard"
# - Observe transcript updating in realtime
# - Stop and verify transcript accuracy
# - Edit if needed and save
```

**STT Testing Checklist:**
- [ ] Microphone permission granted successfully
- [ ] Transcript updates in realtime as you speak
- [ ] Confidence indicator shows for low-accuracy results
- [ ] STT gracefully falls back if unavailable (test in airplane mode)
- [ ] Manual input works when STT disabled
- [ ] Both audio file and transcript save correctly
- [ ] Different locales work (English vs Vietnamese)

**Device-Specific Notes:**
- Some devices may require language pack download on first STT use
- STT accuracy better with Google Play Services installed
- Quiet environment recommended for testing
- Varies by Android version (API 23+ supported, but 26+ recommended for best results)

### Upload to Google Play Console

1. **Create App in Play Console:**
   - Go to [Google Play Console](https://play.google.com/console)
   - Create new app
   - App name: **Voice Flashcards**
   - Package name: `com.example.voice_note_flashcards`
   - Language: English, Vietnamese

2. **Upload AAB:**
   - Go to "Production" track
   - Click "Create new release"
   - Upload `app-release.aab`
   - Release name: `1.0.0-beta (1)`
   - Release notes:
     ```
     Initial beta release
     - Voice recording flashcard creation with REALTIME SPEECH-TO-TEXT
     - See your words transcribed live as you speak!
     - Spaced repetition study system
     - Audio quiz mode
     - Light/dark theme
     - English/Vietnamese support
     ```

3. **Complete Store Listing:**
   - Short description (80 chars max): "Voice flashcard app with live speech-to-text for kids 5+"
   - Full description (4000 chars max): Highlight STT feature prominently
   - App icon (512x512 PNG)
   - Feature graphic (1024x500 PNG)
   - Screenshots (minimum 2, recommend 8) - **Include screenshot showing live transcript**
   - App category: Education
   - Content rating: E for Everyone
   - Privacy policy URL (required)

4. **Submit for Review:**
   - Review all sections
   - Submit app
   - Wait for approval (typically 1-7 days)

---

## 11) ASSETS & PLACEHOLDER FILES

### Required Assets

**Create these PNG files (512x512, transparent background):**

1. `assets/images/app_logo.png` (1024x1024)
   - Panda face with matcha green background
   - Used for launcher icon

2. `assets/images/panda_placeholder.png`
   - Neutral panda face
   - Used in flashcard tiles

3. `assets/images/panda_happy.png`
   - Smiling panda with sparkles
   - Used for correct quiz answers

4. `assets/images/panda_sad.png`
   - Sad panda with encouraging expression
   - Used for wrong quiz answers (gentle, not punitive)

5. `assets/images/panda_wave.png`
   - Panda waving hand
   - Onboarding slide 1

6. `assets/images/panda_mic.png`
   - Panda holding microphone
   - Onboarding slide 2

7. `assets/images/panda_books.png`
   - Panda reading books
   - Onboarding slide 3

### Font Files

Download **Poppins** font from [Google Fonts](https://fonts.google.com/specimen/Poppins):

- `assets/fonts/Poppins-Regular.ttf`
- `assets/fonts/Poppins-Bold.ttf`

Add to `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

### Asset Generation Commands

If you can't create custom images, use placeholder services:

```dart
// In code, add fallback for missing images:
Image.asset(
  'assets/images/panda_happy.png',
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.sentiment_very_satisfied, size: 120);
  },
)
```

---

## 12) GITIGNORE CONFIGURATION

**.gitignore**

```gitignore
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio
*.iml
.gradle
/local.properties
/.idea/
.DS_Store
/build
/captures
.externalNativeBuild
.cxx

# Android keystore & signing
key.properties
key.jks
*.keystore

# Coverage
coverage/

# Test related
.test_coverage.dart

# Generated files
*.g.dart
*.freezed.dart
*.gen.dart
```

---

## 13) README.md TEMPLATE

```markdown
# Voice Flashcards 🐼

A child-friendly (5+) voice note flashcard app for Android, built with Flutter.

## Features ✨

- 🎤 **Voice Recording:** Record audio flashcards easily
- 🗣️ **🆕 Realtime Speech-to-Text:** See your speech transcribed LIVE while recording (on-device)
- ✏️ **Smart Transcript Editing:** Review and edit STT transcript before saving
- 📚 **Smart Study:** Spaced repetition algorithm for optimal learning
- 🎯 **Audio Quiz:** Fun multiple-choice quiz with audio playback
- 🔄 **Flip Cards:** Interactive flip card study mode
- 🌙 **Dark Mode:** Light/dark theme support
- 🌍 **Bilingual:** English & Vietnamese localization
- 💾 **Backup:** Export/import your flashcards as JSON
- 🐼 **Child-Friendly:** Large touch targets, gentle feedback, cute panda theme

## Tech Stack 🛠

- **Framework:** Flutter (Dart 3)
- **Storage:** SharedPreferences (local JSON)
- **Architecture:** Clean Architecture (domain/data/presentation)
- **State Management:** Provider
- **Audio:** `record` + `just_audio`
- **🆕 Speech Recognition:** `speech_to_text` (on-device, realtime)
- **Principles:** SOLID

## Project Structure 📁

```
lib/
├── core/          # Constants, theme, services
├── domain/        # Entities, repositories (interfaces), usecases
├── data/          # Repository implementations, models
└── presentation/  # UI (pages, widgets, providers)
```

## Setup & Build 🚀

### Prerequisites

- Flutter SDK (stable)
- Android SDK (API 35)
- Java JDK 11+

### Development

```bash
# Install dependencies
flutter pub get

# Generate icons
flutter pub run flutter_launcher_icons

# Run app
flutter run
```

### Production Build

```bash
# 1. Create keystore
keytool -genkey -v -keystore key.jks -alias voice_note_alias \
  -keyalg RSA -keysize 2048 -validity 10000

# 2. Setup key.properties
cp key.properties.template key.properties
# Edit with your passwords

# 3. Build release AAB
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

## App Configuration ⚙️

- **Package:** com.example.voice_note_flashcards
- **Min SDK:** 23 (Android 6.0)
- **Target SDK:** 35 (Android 15)
- **Version:** 1.0.0-beta (Build 1)

## Testing 🧪

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Architecture & SOLID 🏗

This project follows **Clean Architecture** and **SOLID principles**:

- **S**ingle Responsibility: Each class has one job
- **O**pen/Closed: Use abstractions for extensibility
- **L**iskov Substitution: Models can replace entities
- **I**nterface Segregation: Focused repository interfaces
- **D**ependency Inversion: Depend on abstractions, inject via constructors

## License 📄

MIT License - feel free to use for learning or personal projects.

## Credits 👏

- Panda illustrations: [Asset source]
- Poppins font: Google Fonts
- Built with ❤️ using Flutter
```

---

## 14) CHANGELOG.md

```markdown
# Changelog

All notable changes to Voice Flashcards will be documented in this file.

## [1.0.0-beta] - 2025-12-10

### Added
- Initial beta release
- Voice recording with microphone permission handling
- **🆕 Realtime Speech-to-Text (STT):** On-device speech recognition using `speech_to_text` package
- **🆕 Live Transcript View:** See transcription update in realtime while recording
- **🆕 Simultaneous Recording:** Audio + STT run together for seamless UX
- **🆕 Confidence Indicator:** Shows STT accuracy warnings if <70%
- **🆕 Graceful STT Fallback:** App continues recording even if STT unavailable
- **🆕 Confirm Transcript Page:** Review and edit STT results before saving
- **🆕 SpeechService:** Dedicated service layer for STT (SOLID compliance)
- **🆕 RecordSttProvider:** Manages recording + STT state with Provider pattern
- Audio playback for flashcards
- Spaced repetition study system (0-5+ levels)
- Flip card study mode with 3D animation
- Audio quiz mode with multiple choice
- Light/dark theme toggle
- English/Vietnamese localization (l10n) including STT-specific strings
- Backup export/import (JSON format)
- Onboarding flow (3 slides)
- Empty states with Panda illustrations
- SharedPreferences local storage
- Clean Architecture implementation (domain/data/presentation)
- SOLID principles compliance
- Unit tests for usecases, repositories, and STT provider
- Widget tests for UI components including recording page
- Android SDK 35 support
- ProGuard configuration for release builds (including STT plugin rules)
- Keystore signing setup

### Configuration
- compileSdk: 35
- targetSdk: 35
- minSdk: 23
- applicationId: com.example.voice_note_flashcards
- versionCode: 1
- versionName: 1.0.0-beta

### Known Issues
- No iOS support (Android only)
- No cloud sync (local storage only)
- No image attachments for flashcards
- Audio files not included in backup export (only JSON metadata)
- Maximum 1000 flashcards limit
- **STT requires on-device language pack** (may need initial download on some devices)
- **STT accuracy varies** by device hardware and ambient noise

### Coming in v1.1.0
- Cloud backup with Firebase
- Image attachments for flashcards
- Statistics & progress tracking
- More quiz types (typing, matching)
- Audio file compression
- Social sharing

### Security Notes
- Keystore and key.properties must not be committed to version control
- Audio files stored locally in app documents directory
- No user authentication or cloud storage in this version
```

---

## 15) OUTPUT FORMAT

When generating code, output each file using this format:

```
=== FILE: pubspec.yaml ===
<full file content>
=== END FILE ===

=== FILE: lib/main.dart ===
<full file content>
=== END FILE ===

=== FILE: lib/core/constants.dart ===
<full file content>
=== END FILE ===

... (continue for all files) ...
```

---

## 16) ACCEPTANCE CRITERIA ✅

Before considering the project complete, verify:

- [ ] **Compilation:** `flutter analyze` shows no errors
- [ ] **Dependencies:** `flutter pub get` succeeds (including `speech_to_text`)
- [ ] **8 Pages Implemented:** Splash, Onboarding, Home, Record, ConfirmTranscript, Detail, Study, Settings
- [ ] **Storage:** SharedPreferences saving/loading works, persists across restarts
- [ ] **Audio:** Recording and playback functional
- [ ] **🆕 Realtime STT:** Speech recognition updates transcript live during recording
- [ ] **🆕 STT Fallback:** App continues recording if STT unavailable, allows manual input
- [ ] **Permissions:** Microphone permission requested and handled properly
- [ ] **Spaced Repetition:** Due cards filter correctly, levels update on study
- [ ] **Quiz:** 3 options generated correctly, feedback shown
- [ ] **Theme:** Light/dark toggle works and persists
- [ ] **Localization:** EN/VI strings display correctly (including STT strings)
- [ ] **Android Config:** compileSdk 35, signing config present, INTERNET permission added
- [ ] **Build:** `flutter build appbundle --release` produces AAB file
- [ ] **Tests:** At least 5 tests pass including STT provider tests (`flutter test`)
- [ ] **Assets:** All 7 panda images referenced (placeholders OK)
- [ ] **Icons:** Launcher icon configured and generated
- [ ] **README:** Complete with build instructions + STT testing notes
- [ ] **CHANGELOG:** Documents v1.0.0-beta including STT feature

---

## 17) PERFORMANCE CONSIDERATIONS

### Optimization Guidelines

1. **Flashcard Limit:**
   - Soft limit: 900 cards (show warning)
   - Hard limit: 1000 cards (block creation)

2. **Audio Files:**
   - Format: M4A (cross-platform, good compression)
   - Max size: 10MB per file
   - Storage: App documents directory (auto-cleaned on uninstall)

3. **List Performance:**
   - Use `ListView.builder` for efficient rendering
   - Implement pagination if >100 cards
   - Debounce search (300ms delay)

4. **Memory Management:**
   - Dispose audio players in page `dispose()`
   - Cancel timers when leaving recording page
   - Clear image cache periodically

5. **SharedPreferences:**
   - JSON size limit: ~10MB (monitor in Settings page)
   - Compress if >1000 flashcards

---

## 18) ACCESSIBILITY REQUIREMENTS

### Child-Friendly (5+ age) Guidelines

1. **Touch Targets:**
   - Minimum: 48x48 dp (Flutter standard)
   - Preferred: 56x56 dp for primary actions
   - Record button: 80x80 dp

2. **Text Sizes:**
   - Titles: 20sp minimum
   - Body text: 16sp minimum
   - Support system font scaling (up to 200%)

3. **Contrast Ratios:**
   - Text vs background: 4.5:1 (WCAG AA)
   - High contrast mode compatible

4. **Feedback:**
   - Visual: Color changes, animations
   - Auditory: Audio playback
   - Haptic: Button presses (optional)

5. **Error Messages:**
   - Always positive/encouraging
   - Use panda reactions (no scary icons)
   - Clear, simple language

6. **Semantic Labels:**
   - Add to all IconButtons
   - Add to all Images
   - Support screen readers (TalkBack)

---

## 19) ERROR HANDLING STRATEGY

### Domain Layer

```dart
// Use Result pattern or simple exceptions
class FlashcardException implements Exception {
  final String message;
  FlashcardException(this.message);
}

class StorageException extends FlashcardException {
  StorageException(String message) : super(message);
}

class AudioException extends FlashcardException {
  AudioException(String message) : super(message);
}

class PermissionDeniedException extends FlashcardException {
  PermissionDeniedException() : super('Permission denied');
}

class ValidationException extends FlashcardException {
  ValidationException(String message) : super(message);
}
```

### Presentation Layer

```dart
// Show user-friendly messages
void handleError(BuildContext context, Exception error) {
  String message;
  
  if (error is PermissionDeniedException) {
    message = 'Cần quyền ghi âm để sử dụng tính năng này';
    _showPermissionDialog(context);
  } else if (error is ValidationException) {
    message = error.message;
  } else if (error is StorageException) {
    message = 'Không thể lưu dữ liệu. Vui lòng thử lại.';
  } else if (error is AudioException) {
    message = 'Lỗi khi ghi/phát âm thanh. Vui lòng kiểm tra micro.';
  } else {
    message = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
```

---

## 20) FINAL CHECKLIST FOR AI GENERATOR

When generating this project, ensure:

### Code Generation
- [ ] All files use correct folder structure
- [ ] All imports are correct
- [ ] All classes follow SOLID principles
- [ ] Dependency injection via constructors
- [ ] No global singletons (except logger)
- [ ] Proper error handling in all usecases
- [ ] Async/await used correctly
- [ ] Null safety enabled

### Android Configuration
- [ ] AndroidManifest.xml has all permissions
- [ ] build.gradle has SDK 35, versionCode 1
- [ ] Signing config reads from key.properties
- [ ] ProGuard rules included
- [ ] Launcher icon config in pubspec.yaml

### Features Implementation
- [ ] All 8 pages fully functional (including ConfirmTranscriptPage)
- [ ] Navigation between pages works
- [ ] SharedPreferences CRUD complete
- [ ] Audio recording with permission check
- [ ] 🆕 **Realtime STT:** Speech recognition runs simultaneously with audio recording
- [ ] 🆕 **LiveTranscriptView:** Updates in realtime as user speaks
- [ ] 🆕 **STT Graceful Fallback:** Continues recording if STT unavailable
- [ ] 🆕 **Confidence Indicator:** Shows STT accuracy warnings if <70%
- [ ] Audio playback with controls
- [ ] Spaced repetition algorithm implemented
- [ ] Quiz logic with 3 random options
- [ ] Theme toggle persists
- [ ] Localization works for EN/VI

### UI/UX
- [ ] All 7 panda images referenced
- [ ] Colors match matcha/panda theme
- [ ] Poppins font configured
- [ ] Touch targets >= 48dp
- [ ] Empty states have panda + CTA
- [ ] Loading indicators where needed
- [ ] Confirmation dialogs for destructive actions

### Testing
- [ ] At least 3 unit/widget tests
- [ ] Tests use proper mocking
- [ ] Tests pass (`flutter test`)

### Documentation
- [ ] README with setup instructions
- [ ] README with build commands
- [ ] CHANGELOG with v1.0.0-beta
- [ ] key.properties.template included
- [ ] .gitignore includes sensitive files
- [ ] Code comments for complex logic

### Build & Release
- [ ] `flutter analyze` passes
- [ ] `flutter pub get` works
- [ ] `flutter build appbundle --release` produces AAB
- [ ] AAB size reasonable (<50MB)
- [ ] Release notes prepared

---

## 🎯 SUMMARY

This prompt provides a **complete specification** for building a production-ready Flutter voice flashcard app for Android. The app:

- ✅ Uses **Flutter + SharedPreferences** (no complex backend)
- ✅ **🆕 Realtime Speech-to-Text on-device** (`speech_to_text` package)
- ✅ **🆕 Simultaneous audio recording + STT** with live transcript updates
- ✅ **🆕 Graceful fallback** when STT unavailable
- ✅ Follows **Clean Architecture** with clear folder structure
- ✅ Adheres to **SOLID principles** throughout (including `SpeechService` separation)
- ✅ Configured for **Android SDK 35** with release signing
- ✅ Ready to build **app-release.aab** for Google Play Console
- ✅ **No iOS support** (Android only as requested)
- ✅ Includes all configuration files, comprehensive tests, and documentation
- ✅ Child-friendly design (5+) with Panda + Matcha green theme

**Key Innovation:** The **Realtime STT** feature provides a superior UX where users see their speech transcribed live while recording, can edit it, and save both audio + text together - perfect for educational flashcard apps!

**Result:** A complete, buildable, uploadable Android app bundle ready for Google Play Console.

---

**Version:** 1.1 Final (Android Only + Realtime STT)  
**Last Updated:** 2025-12-10  
**Target:** Google Play Console Release  
**New Feature:** 🎤 **On-device Realtime Speech-to-Text**

