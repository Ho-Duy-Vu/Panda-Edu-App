# 🎯 THIẾT KẾ CHI TIẾT: Collections & Advanced Study Modes

## Tổng quan

Bổ sung 3 tính năng lớn cho PandaEdu:
1. **Collections** - Quản lý flashcards theo thư mục
2. **Audio Quiz Mode** - Học bằng cách nghe và đoán
3. **Speak Mode** - Luyện phát âm với Speech-to-Text

---

## 📊 Kiến trúc dữ liệu

### 1. Collection Entity
```dart
class Collection {
  String id;
  String name;
  String? description;
  DateTime createdAt;
  int flashcardCount; // Tự động tính
}
```

### 2. Flashcard Entity (Cập nhật)
```dart
class Flashcard {
  // Existing fields...
  String? collectionId;     // NEW: ID của collection
  int correctCount;         // NEW: Số lần đúng
  int incorrectCount;       // NEW: Số lần sai
}
```

### 3. StudyStats Entity (Mới)
```dart
class StudyStats {
  String flashcardId;
  StudyMode mode; // normal, audio_quiz, speak
  int correctCount;
  int incorrectCount;
  double accuracy; // %
  DateTime lastStudied;
}
```

---

## 🗂️ Feature 1: Collections System

### Architecture
```
lib/
├── domain/
│   ├── entities/
│   │   └── collection.dart ✅ (Đã tạo)
│   └── repositories/
│       └── collection_repository.dart (Cần tạo)
├── data/
│   ├── models/
│   │   └── collection_model.dart ✅ (Đã tạo)
│   └── repositories/
│       └── collection_repository_impl.dart (Cần tạo)
└── presentation/
    ├── providers/
    │   └── collection_provider.dart (Cần tạo)
    └── pages/
        └── collections_page.dart (Cần tạo)
```

### UI Flow

#### CollectionsPage
```
AppBar:
  ← Bộ sưu tập
  [+ Add] icon

Body:
  ListView:
    - CollectionCard("📁 Từ vựng IELTS", 32 cards)
    - CollectionCard("📁 Lập trình Flutter", 10 cards)
    - CollectionCard("📂 Chưa phân loại", 5 cards) // Default collection

FloatingActionButton:
  + Tạo thư mục mới
```

#### CRUD Operations
1. **Create**: Dialog nhập tên + mô tả
2. **Read**: Tap vào collection → Xem flashcards trong đó
3. **Update**: Long press → Đổi tên/mô tả
4. **Delete**: Long press → Xóa (move flashcards về "Chưa phân loại")

### Storage
```json
// SharedPreferences key: "collections"
[
  {
    "id": "uuid-1",
    "name": "Từ vựng IELTS",
    "description": "Vocabulary for IELTS test",
    "createdAt": "2025-12-12T...",
    "flashcardCount": 32
  }
]
```

---

## 🎧 Feature 2: Audio Quiz Mode

### UI Design
```
┌─────────────────────────────────┐
│ ← Audio Quiz  1/10         ⚙️   │
├─────────────────────────────────┤
│                                 │
│        🔊                        │
│   [  Play Audio  ]              │
│                                 │
│   ┌─────────────────────────┐  │
│   │  Đoán xem đây là gì?     │  │
│   │                          │  │
│   │  Tap để xem câu trả lời  │  │
│   └─────────────────────────┘  │
│                                 │
│   [✓ Đúng]      [✗ Sai]        │
└─────────────────────────────────┘
```

### Logic Flow
```
1. Load random flashcard có audioPath
2. Auto-play audio (hoặc tap để nghe lại)
3. User đoán → Tap card để flip
4. User chọn Đúng/Sai
5. Cập nhật correctCount/incorrectCount
6. Next card
```

### Implementation
```dart
class AudioQuizPage extends StatefulWidget {
  final List<Flashcard> flashcards; // Only cards with audio

  @override
  State<AudioQuizPage> createState() => _AudioQuizPageState();
}

class _AudioQuizPageState extends State<AudioQuizPage> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playAudio() async {
    final flashcard = widget.flashcards[_currentIndex];
    if (flashcard.audioPath != null) {
      await _audioPlayer.play(DeviceFileSource(flashcard.audioPath!));
    }
  }

  void _markCorrect() {
    // Update flashcard stats
    // Next card
  }

  void _markIncorrect() {
    // Update flashcard stats
    // Next card
  }
}
```

---

## 📝 Feature 3: Speak Mode (Pronunciation Check)

### UI Design
```
┌─────────────────────────────────┐
│ ← Speak Mode   1/10        ⚙️   │
├─────────────────────────────────┤
│  Câu hỏi:                       │
│  ┌─────────────────────────┐   │
│  │ What is photosynthesis? │   │
│  └─────────────────────────┘   │
│                                 │
│  Hãy nói:                       │
│  "Photosynthesis is..."         │
│                                 │
│      🎤                          │
│  [  Tap để nói  ]               │
│                                 │
│  ─────────────────────          │
│  📊 Kết quả:                    │
│  ✅ Độ chính xác: 84%           │
│  ⚠️  Gợi ý: âm /θ/ chưa rõ     │
│  ─────────────────────          │
│                                 │
│  [Skip]    [Thử lại]   [Next]  │
└─────────────────────────────────┘
```

### Logic Flow
```
1. Show flashcard title (Question)
2. Show transcript preview (Target answer)
3. Tap mic → Start recording
4. Stop recording → Run Speech-to-Text
5. Compare STT result with flashcard.transcript
6. Calculate accuracy (similarity %)
7. Show feedback + suggestions
8. Allow retry or next
```

### Accuracy Calculation
```dart
double calculateSimilarity(String answer, String correct) {
  // Option 1: Simple word matching
  final answerWords = answer.toLowerCase().split(' ');
  final correctWords = correct.toLowerCase().split(' ');
  
  int matches = 0;
  for (var word in correctWords) {
    if (answerWords.contains(word)) matches++;
  }
  
  return (matches / correctWords.length) * 100;
}

// Option 2: Levenshtein Distance (advanced)
int levenshteinDistance(String s1, String s2) {
  // Implementation...
}

double calculateAccuracy(String answer, String correct) {
  int distance = levenshteinDistance(answer, correct);
  int maxLen = max(answer.length, correct.length);
  return ((maxLen - distance) / maxLen) * 100;
}
```

### Feedback Generation
```dart
String generateFeedback(String answer, String correct, double accuracy) {
  if (accuracy >= 95) return "Xuất sắc! Phát âm rất chuẩn.";
  if (accuracy >= 80) return "Tốt! Còn một vài chỗ cần cải thiện.";
  if (accuracy >= 60) return "Khá! Hãy luyện tập thêm.";
  return "Cần cố gắng nhiều hơn. Nghe lại audio mẫu.";
}

List<String> suggestImprovements(String answer, String correct) {
  List<String> suggestions = [];
  
  // Check missing words
  final correctWords = correct.toLowerCase().split(' ');
  final answerWords = answer.toLowerCase().split(' ');
  
  for (var word in correctWords) {
    if (!answerWords.contains(word)) {
      suggestions.add("Thiếu từ: '$word'");
    }
  }
  
  // Check pronunciation issues (simplified)
  if (answer.contains('s') && correct.contains('th')) {
    suggestions.add("Chú ý phát âm /θ/ (th), không phải /s/");
  }
  
  return suggestions;
}
```

---

## 🎨 Navigation Updates

### HomePage - Thêm Study Mode Options
```dart
// In AppBar or FloatingActionButton menu
PopupMenuButton(
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'normal_study',
      child: Text('📚 Ôn tập thường'),
    ),
    PopupMenuItem(
      value: 'audio_quiz',
      child: Text('🎧 Audio Quiz'),
    ),
    PopupMenuItem(
      value: 'speak_mode',
      child: Text('🎤 Speak Mode'),
    ),
    PopupMenuItem(
      value: 'collections',
      child: Text('🗂️ Bộ sưu tập'),
    ),
  ],
)
```

### Routing
```dart
// main.dart
case '/collections':
  return MaterialPageRoute(builder: (_) => CollectionsPage());

case '/audio-quiz':
  final flashcards = settings.arguments as List<Flashcard>;
  return MaterialPageRoute(
    builder: (_) => AudioQuizPage(flashcards: flashcards),
  );

case '/speak-mode':
  final flashcards = settings.arguments as List<Flashcard>;
  return MaterialPageRoute(
    builder: (_) => SpeakModePage(flashcards: flashcards),
  );
```

---

## 📈 Statistics & Analytics

### StudyStatsProvider
```dart
class StudyStatsProvider extends ChangeNotifier {
  Map<String, StudyStats> _stats = {};

  void recordAnswer({
    required String flashcardId,
    required StudyMode mode,
    required bool isCorrect,
  }) {
    final key = '${flashcardId}_$mode';
    final stats = _stats[key] ?? StudyStats(...);
    
    if (isCorrect) {
      stats.correctCount++;
    } else {
      stats.incorrectCount++;
    }
    
    stats.accuracy = (stats.correctCount / (stats.correctCount + stats.incorrectCount)) * 100;
    stats.lastStudied = DateTime.now();
    
    _stats[key] = stats;
    notifyListeners();
    _saveStats();
  }

  StudyStats? getStats(String flashcardId, StudyMode mode) {
    return _stats['${flashcardId}_$mode'];
  }

  Map<StudyMode, double> getOverallAccuracy() {
    // Calculate average accuracy per mode
  }
}
```

---

## ✅ Implementation Checklist

### Phase 1: Collections (2-3 giờ)
- [x] Collection & CollectionModel entities
- [x] Update Flashcard entity với collectionId
- [ ] CollectionRepository & Implementation
- [ ] CollectionProvider
- [ ] CollectionsPage UI
- [ ] Integration với HomePage (filter)

### Phase 2: Audio Quiz Mode (1-2 giờ)
- [ ] AudioQuizPage UI
- [ ] Audio playback logic
- [ ] Stats tracking (correct/incorrect)
- [ ] Result screen with accuracy

### Phase 3: Speak Mode (2-3 giờ)
- [ ] SpeakModePage UI
- [ ] STT integration (reuse existing service)
- [ ] Similarity calculation
- [ ] Feedback generation
- [ ] Pronunciation suggestions

### Phase 4: Integration & Polish (1 giờ)
- [ ] Update navigation
- [ ] Add study mode selection
- [ ] Statistics dashboard
- [ ] Testing & bug fixes

**Tổng thời gian ước tính: 6-9 giờ**

---

## 🚨 Lưu ý quan trọng

1. **TTS Issue**: Cần fix xong lỗi TTS (MissingPluginException) trước khi triển khai Audio Quiz
2. **Storage Migration**: Cần migration script để update flashcards cũ với new fields
3. **Performance**: Collections với nhiều flashcards cần pagination
4. **STT Quality**: Speak Mode accuracy phụ thuộc vào chất lượng STT engine

---

## 📝 Migration Script

```dart
Future<void> migrateFlashcardsV2() async {
  final prefs = await SharedPreferences.getInstance();
  final flashcardsJson = prefs.getString('flashcards');
  
  if (flashcardsJson != null) {
    List<dynamic> list = jsonDecode(flashcardsJson);
    
    // Add new fields với default values
    for (var item in list) {
      item['collectionId'] ??= null;
      item['correctCount'] ??= 0;
      item['incorrectCount'] ??= 0;
    }
    
    await prefs.setString('flashcards', jsonEncode(list));
  }
}
```

---

**Bạn muốn tôi:**
A) Triển khai toàn bộ ngay bây giờ (sẽ mất nhiều context và tool calls)
B) Triển khai từng phase một, test xong mới sang phase tiếp
C) Chỉ làm Collections trước (tính năng quan trọng nhất)
D) Chỉ làm Study Modes (Audio Quiz + Speak Mode)

**Hoặc có thay đổi/điều chỉnh gì không?**

