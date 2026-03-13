# PandaEdu - Voice Flashcard App 🐼

Ứng dụng flashcard với tính năng ghi âm và nhận dạng giọng nói (Speech-to-Text) theo kiến trúc Clean Architecture với SOLID principles.

## ✨ Tính năng chính

### 1. Ghi âm với Speech-to-Text Realtime
- ✅ Ghi âm giọng nói (tối đa 60 giây)
- ✅ Nhận dạng giọng nói realtime (on-device)
- ✅ Hiển thị transcript trực tiếp trong khi ghi
- ✅ Chỉnh sửa transcript trước khi lưu
- ✅ Tự động tạo tiêu đề từ nội dung

### 2. Quản lý Flashcards
- ✅ Danh sách flashcard với search & filter
- ✅ Sắp xếp: Mới nhất, Tên A-Z, Cần ôn
- ✅ Pull to refresh
- ✅ Audio playback inline
- ✅ Favorite flashcards

### 3. Học tập thông minh
- ✅ Flip Card View (3D animation)
- ✅ Spaced Repetition System (SRS)
- ✅ 5 levels: Lại, Được, Dễ
- ✅ Auto-schedule review dates
- 🚧 Audio Quiz (đang phát triển)

### 4. Cài đặt & Backup
- ✅ Dark/Light mode
- ✅ Export/Import JSON
- ✅ Clear all data
- ✅ Localization (EN/VI)

## 🏗️ Kiến trúc Clean Architecture - 3 Layers

```
lib/
├── core/               # Constants, Theme, Services
├── domain/             # Entities, Repositories (abstract), Usecases
├── data/               # Models, Repository implementations
└── presentation/       # Providers, Pages, Widgets
```

## 🚀 Chạy ứng dụng

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk --release

# Build AAB (Google Play)
flutter build appbundle --release
```

## 📦 Tech Stack

- Flutter SDK ^3.10.0
- Provider (State Management)
- SharedPreferences (Storage)
- speech_to_text, record, audioplayers

## 📱 Android Config

- compileSdk: 35, targetSdk: 35, minSdk: 23
- Permissions: RECORD_AUDIO, INTERNET

**Built with ❤️ using Clean Architecture & SOLID Principles**

## 👤 Tác giả

| | |
|---|---|
| **Họ và tên** | Hồ Duy Vũ |
| **Email** | [duyvu11092004@gmail.com](mailto:duyvu11092004@gmail.com) |
| **Số điện thoại** | [0932694273](tel:0932694273) |
| **Địa chỉ** | Thu Duc, TP.HCM, Việt Nam |
| **LinkedIn** | [linkedin.com/in/hoduyvu](https://www.linkedin.com/in/hoduyvu) |
| **GitHub** | [github.com/Ho-Duy-Vu](https://github.com/Ho-Duy-Vu) |
| **YouTube** | [youtube.com/@vuhoduy9075](https://www.youtube.com/@vuhoduy9075) |
