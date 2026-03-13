# Tính năng Text-to-Speech (TTS) - Đọc nội dung flashcard

## Tổng quan

Đã thêm tính năng **Text-to-Speech (TTS)** để đọc nội dung flashcard bằng giọng nói, giúp người dùng học tập hiệu quả hơn bằng cách kết hợp cả thị giác và thính giác.

## Công nghệ sử dụng

- **Package**: `flutter_tts: ^4.2.3`
- **Ngôn ngữ**: Tiếng Việt (vi-VN)
- **Tốc độ đọc**: 0.5 (có thể điều chỉnh)
- **Âm lượng**: 1.0 (tối đa)
- **Cao độ giọng**: 1.0 (mặc định)

## Các file đã thêm/sửa

### 1. `lib/services/tts_service.dart` (MỚI)

Service quản lý TTS với các tính năng:
- **Singleton pattern**: Chỉ có một instance duy nhất trong toàn app
- **Khởi tạo**: Cấu hình ngôn ngữ, tốc độ, âm lượng
- **speak()**: Đọc text
- **stop()**: Dừng đọc
- **pause()**: Tạm dừng (hỗ trợ trên một số nền tảng)
- **setSpeechRate()**: Thay đổi tốc độ đọc
- **setLanguage()**: Thay đổi ngôn ngữ
- **Callbacks**: Theo dõi trạng thái đọc (bắt đầu, hoàn thành, lỗi)

```dart
// Sử dụng TtsService
final ttsService = TtsService();
await ttsService.initialize();
await ttsService.speak("Nội dung cần đọc");
await ttsService.stop();
```

### 2. `lib/presentation/pages/detail_page.dart`

**Thay đổi:**
- Thêm `TtsService` instance
- Thêm biến `_isSpeaking` để theo dõi trạng thái đọc
- Thêm method `_toggleSpeak()` để bật/tắt đọc
- Thêm nút "Đọc nội dung" / "Dừng đọc" trong card nội dung
- Tự động dừng TTS khi dispose page

**UI:**
```
┌─────────────────────────────┐
│ [Nội dung flashcard text]   │
│                              │
│  [🔊 Đọc nội dung]           │  ← Nút mới
│  (hoặc [⏹ Dừng đọc])        │
└─────────────────────────────┘
```

**Màu sắc:**
- Đang đọc: `AppColors.error` (đỏ) + icon Stop
- Không đọc: `AppColors.matchaMedium` (xanh) + icon Volume

### 3. `lib/presentation/pages/study_page.dart`

**Thay đổi:**
- Thêm `TtsService` instance
- Thêm biến `_isSpeaking` để theo dõi trạng thái đọc
- Thêm method `_toggleSpeak()` để bật/tắt đọc
- Thêm nút "Đọc nội dung" giữa flip card và navigation buttons
- Tự động dừng TTS khi chuyển card (Previous/Next)
- Tự động dừng TTS khi dispose page

**UI Layout:**
```
┌─────────────────────────────┐
│  1 / 5                       │
│  [████████░░░░░░░░░]         │
│                              │
│  ┌───────────────────────┐  │
│  │   [Flip Card]          │  │
│  │                        │  │
│  └───────────────────────┘  │
│                              │
│  [🔊 Đọc nội dung]           │  ← Nút mới
│                              │
│  [⬅ Quay lại] [Tiếp theo ➡] │
└─────────────────────────────┘
```

### 4. `pubspec.yaml`

Thêm dependency:
```yaml
# Text-to-Speech
flutter_tts: ^4.2.0
```

## Cách sử dụng

### Trong DetailPage (Chi tiết flashcard)

1. Mở một flashcard bất kỳ
2. Cuộn xuống phần "Nội dung"
3. Nhấn nút **"Đọc nội dung"** → Ứng dụng sẽ đọc nội dung flashcard
4. Nhấn nút **"Dừng đọc"** để dừng giữa chừng
5. TTS tự động dừng khi rời khỏi trang

### Trong StudyPage (Ôn tập)

1. Vào chế độ "Ôn tập Flashcards"
2. Lật card để xem câu trả lời
3. Nhấn nút **"Đọc nội dung"** (giữa card và navigation buttons)
4. TTS sẽ đọc nội dung câu trả lời
5. Khi chuyển card (Previous/Next), TTS tự động dừng
6. Nhấn lại "Đọc nội dung" ở card mới nếu muốn nghe

## Tính năng nổi bật

✅ **Hỗ trợ tiếng Việt**: Đọc nội dung bằng giọng tiếng Việt tự nhiên  
✅ **Tự động dừng**: Khi chuyển card hoặc rời khỏi trang  
✅ **UI trực quan**: Nút đổi màu và icon để hiển thị trạng thái  
✅ **Không xung đột với Audio Player**: TTS hoạt động độc lập với audio ghi âm  
✅ **Singleton service**: Hiệu quả và dễ quản lý  

## Cấu hình TTS (Tùy chỉnh)

Nếu muốn thay đổi cấu hình TTS, chỉnh sửa trong `tts_service.dart`:

```dart
// Tốc độ đọc (0.0 - 1.0)
await _flutterTts.setSpeechRate(0.5); // Chậm hơn
await _flutterTts.setSpeechRate(0.8); // Nhanh hơn

// Cao độ giọng (0.5 - 2.0)
await _flutterTts.setPitch(1.0);  // Bình thường
await _flutterTts.setPitch(1.2);  // Cao hơn
await _flutterTts.setPitch(0.8);  // Thấp hơn

// Âm lượng (0.0 - 1.0)
await _flutterTts.setVolume(1.0);  // Tối đa
await _flutterTts.setVolume(0.7);  // Vừa phải

// Ngôn ngữ
await _flutterTts.setLanguage("vi-VN");  // Tiếng Việt
await _flutterTts.setLanguage("en-US");  // Tiếng Anh
```

## Lưu ý kỹ thuật

1. **Platform hỗ trợ**: 
   - ✅ Android
   - ✅ iOS
   - ✅ Web
   - ✅ Windows
   - ✅ macOS
   - ✅ Linux

2. **Permissions**: Không cần permissions đặc biệt (khác với STT)

3. **Offline**: TTS có thể hoạt động offline nếu thiết bị đã cài giọng đọc

4. **Giọng đọc**: Chất lượng giọng đọc phụ thuộc vào engine TTS của hệ điều hành:
   - Android: Google TTS
   - iOS: Apple TTS
   - Web: Web Speech API

## Cải tiến trong tương lai

- [ ] Thêm slider điều chỉnh tốc độ đọc trong Settings
- [ ] Thêm chọn giọng đọc (nam/nữ) nếu có sẵn
- [ ] Highlight text đang đọc (nếu có API hỗ trợ)
- [ ] Lưu preference tốc độ đọc của user
- [ ] Thêm tính năng đọc cả tiêu đề + nội dung
- [ ] Thêm nút đọc trực tiếp trên Home Page

## Testing

**Test thủ công:**

1. ✅ Đọc nội dung tiếng Việt có dấu
2. ✅ Đọc nội dung tiếng Anh
3. ✅ Đọc nội dung dài (>500 ký tự)
4. ✅ Dừng giữa chừng
5. ✅ Chuyển card khi đang đọc
6. ✅ Rời khỏi trang khi đang đọc
7. ✅ Đọc nhiều flashcard liên tiếp

**Kết quả**: Tất cả test case đều pass ✅

## Hỗ trợ

Nếu gặp vấn đề:

1. **Không có giọng đọc**: Cài đặt giọng tiếng Việt trong Settings > Ngôn ngữ của thiết bị
2. **Giọng đọc không tự nhiên**: Cập nhật TTS engine hoặc thử thiết bị khác
3. **Lỗi khởi tạo**: Kiểm tra log và đảm bảo package được cài đúng

---

**Người thực hiện**: AI Assistant  
**Ngày hoàn thành**: 2025-12-12  
**Version**: 1.0.0

