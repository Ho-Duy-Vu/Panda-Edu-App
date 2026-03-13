# 🔧 Sửa lỗi TTS không đọc được

## Vấn đề: Bấm "Đọc nội dung" nhưng không có âm thanh

### Nguyên nhân có thể

1. **Thiết bị chưa cài giọng đọc tiếng Việt**
2. **TTS engine chưa được cấu hình đúng**
3. **Âm lượng thiết bị bị tắt hoặc quá nhỏ**
4. **TTS engine không hỗ trợ trên platform hiện tại**

---

## ✅ Giải pháp

### 🪟 Windows

#### Bước 1: Kiểm tra log
Mở terminal và chạy app với log:
```bash
cd pandaedu
flutter run -d windows
```

Sau đó bấm nút "Đọc nội dung" và xem log trong console:
- `🔊 [TTS] Initializing TTS Service...` - Đang khởi tạo
- `✅ [TTS] TTS Service initialized successfully` - Khởi tạo thành công
- `🔊 [TTS] Speaking: "..."` - Đang đọc
- `❌ [TTS] Error: ...` - Có lỗi

#### Bước 2: Cài đặt giọng đọc tiếng Việt

1. Mở **Settings** → **Time & Language** → **Speech**
2. Chọn **Manage voices** → **Add voices**
3. Tìm và tải **Vietnamese (Vietnam)** hoặc **Vietnamese - An (Natural)**
4. Sau khi tải xong, chọn làm giọng mặc định

#### Bước 3: Kiểm tra âm lượng
- Bật âm thanh hệ thống
- Tăng âm lượng lên tối đa
- Kiểm tra mixer âm thanh: đảm bảo app không bị mute

#### Bước 4: Test giọng đọc
Mở **Settings** → **Accessibility** → **Narrator** và test giọng đọc xem có hoạt động không.

---

### 🤖 Android

#### Bước 1: Cài đặt Google TTS
```
Settings → System → Languages & input → 
Text-to-speech output → Preferred engine
```
- Chọn **Google Text-to-speech Engine**
- Tap vào **Settings** (biểu tượng bánh răng)
- Chọn **Install voice data**
- Tải **Tiếng Việt (Vietnamese)**

#### Bước 2: Test giọng đọc
Trong **Text-to-speech output**, tap vào **"Listen to an example"** để test.

#### Bước 3: Kiểm tra permissions
Đảm bảo app có quyền truy cập âm thanh.

---

### 🍎 iOS

#### Bước 1: Cài đặt giọng đọc
```
Settings → Accessibility → Spoken Content → Voices
```
- Chọn **Vietnamese**
- Tải giọng đọc chất lượng cao (Enhanced Quality)

#### Bước 2: Enable Speak Selection
```
Settings → Accessibility → Spoken Content
```
- Bật **Speak Selection**
- Test bằng cách chọn text và tap "Speak"

---

## 🐛 Debug với Code

Nếu vẫn không hoạt động, thêm code debug:

### Trong `detail_page.dart` hoặc `study_page.dart`:

```dart
Future<void> _toggleSpeak() async {
  print('🐛 [DEBUG] Toggle speak called, isSpeaking: $_isSpeaking');
  print('🐛 [DEBUG] Transcript: ${_currentFlashcard.transcript}');
  
  if (_isSpeaking) {
    await _ttsService.stop();
    setState(() => _isSpeaking = false);
  } else {
    setState(() => _isSpeaking = true);
    
    // Test với text đơn giản trước
    final success = await _ttsService.speak("Xin chào");
    print('🐛 [DEBUG] Speak result: $success');
    
    if (!success) {
      // Thử với tiếng Anh
      await _ttsService.setLanguage("en-US");
      final successEN = await _ttsService.speak("Hello world");
      print('🐛 [DEBUG] English speak result: $successEN');
    }
  }
}
```

---

## 🔍 Kiểm tra code đã cập nhật

### File: `lib/services/tts_service.dart`

Đã thêm:
- ✅ Logging chi tiết
- ✅ Error handling
- ✅ Fallback từ tiếng Việt sang tiếng Anh
- ✅ Return `bool` từ `speak()` để biết thành công hay không
- ✅ Handler cho `setCancelHandler`

### File: `lib/presentation/pages/detail_page.dart` & `study_page.dart`

Đã thêm:
- ✅ Hiển thị SnackBar nếu TTS thất bại
- ✅ Sync state với TTS service callback
- ✅ Kiểm tra `mounted` trước khi setState

---

## 📊 Test cases

Chạy các test sau:

| Test | Kết quả mong đợi |
|------|------------------|
| Bấm "Đọc nội dung" với text tiếng Việt | Đọc được |
| Bấm "Đọc nội dung" với text tiếng Anh | Đọc được (hoặc fallback) |
| Bấm "Dừng đọc" khi đang đọc | Dừng ngay lập tức |
| Chuyển card khi đang đọc (Study Page) | Tự động dừng |
| Rời khỏi page khi đang đọc | Tự động dừng, không crash |
| Đọc text rỗng | Không đọc, log warning |
| Đọc text dài (>500 từ) | Đọc hết hoặc có thể dừng giữa chừng |

---

## 🆘 Vẫn không hoạt động?

### Kiểm tra console log

Chạy app và quan sát console output:

**Thành công:**
```
🔊 [TTS] Initializing TTS Service...
🔊 [TTS] Available languages: [vi-VN, en-US, ...]
🔊 [TTS] Language set to: vi-VN
🔊 [TTS] Settings: rate=0.5, volume=1.0, pitch=1.0
✅ [TTS] TTS Service initialized successfully
🔊 [TTS] Speaking: "Xin chào..."
✅ [TTS] Speak command successful
🔊 [TTS] Started speaking
🔊 [TTS] Completed speaking
```

**Lỗi:**
```
❌ [TTS] Failed to initialize: ...
⚠️ [TTS] Vietnamese not available, falling back to en-US
❌ [TTS] Error speaking: ...
```

### Giải pháp tạm thời

Nếu tiếng Việt không hoạt động, sửa trong `tts_service.dart`:

```dart
// Dùng tiếng Anh tạm thời
await _flutterTts.setLanguage("en-US");
```

Hoặc cài thêm package TTS khác:
```yaml
dependencies:
  text_to_speech: ^0.2.3  # Alternative package
```

---

## 📞 Liên hệ hỗ trợ

Nếu vẫn gặp vấn đề, cung cấp thông tin:
1. Platform (Windows/Android/iOS)
2. Console log đầy đủ
3. Phiên bản Flutter: `flutter --version`
4. Giọng đọc đã cài: (chụp màn hình Settings)

---

**Cập nhật**: 2025-12-12  
**Trạng thái**: Đã thêm logging và error handling

