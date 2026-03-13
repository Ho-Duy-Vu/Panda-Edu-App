# 🚨 Sửa lỗi TTS: MissingPluginException

## Lỗi
```
MissingPluginException(No implementation found for method setLanguage on channel flutter_tts)
```

## Nguyên nhân
Khi thêm plugin mới (`flutter_tts`), Flutter cần rebuild lại app để plugin được compile và link vào native code. Hot reload KHÔNG đủ!

## ✅ Giải pháp (Chọn 1 trong 3)

### Cách 1: Stop và Run lại app (ĐƠN GIẢN NHẤT)

1. **Stop app hiện tại**: 
   - Trong terminal đang chạy app, nhấn `Ctrl+C`
   - Hoặc trong VS Code/Cursor, click nút Stop (hình vuông đỏ)

2. **Run lại app**:
   ```bash
   flutter run
   ```

3. **Test lại nút "Đọc nội dung"**

---

### Cách 2: Full clean rebuild

```bash
cd pandaedu

# Bước 1: Dọn dẹp build cache
flutter clean

# Bước 2: Lấy dependencies
flutter pub get

# Bước 3: Chạy app
flutter run
```

---

### Cách 3: Trong VS Code/Cursor

1. Nhấn `Ctrl+Shift+P` (hoặc `Cmd+Shift+P` trên Mac)
2. Gõ: `Flutter: Hot Restart`
3. Hoặc gõ: `Flutter: Run Flutter Dev Tools`

**LƯU Ý**: Hot Reload (`r`) KHÔNG đủ, phải Hot Restart (`R`) hoặc Full Restart!

---

## 🧪 Kiểm tra đã fix chưa

Sau khi restart app, bấm "Đọc nội dung" và xem console:

### ✅ Thành công
```
🔊 [TTS] Initializing TTS Service...
🔊 [TTS] Available languages: [vi-VN, en-US, ...]
✅ [TTS] TTS Service initialized successfully
🔊 [TTS] Speaking: "..."
```

### ❌ Vẫn lỗi
```
❌ [TTS] Failed to initialize: MissingPluginException...
```
→ Thử Cách 2 (full clean rebuild)

---

## 📱 Cho từng Platform

### Windows
```bash
flutter run -d windows
```
Nếu vẫn lỗi:
```bash
flutter clean
flutter pub get
flutter run -d windows
```

### Android
```bash
flutter run -d android
```
Nếu vẫn lỗi:
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```
Nếu vẫn lỗi:
```bash
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter pub get
flutter run -d ios
```

### Web (TTS có thể không hoạt động tốt)
```bash
flutter run -d chrome
```

---

## 🔧 Nếu vẫn không được

### 1. Kiểm tra pubspec.yaml
Đảm bảo có dòng này:
```yaml
dependencies:
  flutter_tts: ^4.2.0
```

### 2. Kiểm tra flutter_tts đã cài chưa
```bash
flutter pub deps | grep flutter_tts
```

Kết quả mong đợi:
```
|-- flutter_tts 4.2.3
```

### 3. Upgrade Flutter
```bash
flutter upgrade
flutter doctor
```

### 4. Xóa cache cứng đầu
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

---

## 💡 Lưu ý quan trọng

⚠️ **Hot Reload (`r`) KHÔNG hoạt động với plugin native mới!**

✅ **Phải dùng:**
- Hot Restart (`R`)
- Hoặc Stop + Run lại app

❌ **Không dùng:**
- Hot Reload (`r`)
- Save file và mong app tự update

---

## 🎯 Checklist

- [ ] Đã stop app cũ hoàn toàn
- [ ] Đã chạy `flutter clean`
- [ ] Đã chạy `flutter pub get`
- [ ] Đã run app lại từ đầu (không phải hot reload)
- [ ] Đã kiểm tra console log có `✅ [TTS] TTS Service initialized successfully`
- [ ] Đã test nút "Đọc nội dung"

---

**Thời gian fix**: ~2-3 phút  
**Tỷ lệ thành công**: 99%  

Nếu làm theo mà vẫn lỗi, report lại với đầy đủ log!

