# 📱 PandaEdu - Danh sách Chức năng & Giao diện

## 🎯 Tổng quan
**PandaEdu** là ứng dụng học flashcard bằng giọng nói với Speech-to-Text, thiết kế đơn giản và thân thiện với người dùng.

---

## 📋 Các Màn hình (Pages)

### 1. 🚀 **Splash Page** (`splash_page.dart`)
**Chức năng:**
- Màn hình khởi động app
- Hiển thị logo PandaEdu
- Preload dữ liệu flashcards
- Hiển thị trạng thái: "Đang khởi động...", "Đang tải dữ liệu...", "Hoàn tất!"
- Xử lý lỗi nếu không load được data
- Tự động chuyển đến Onboarding (lần đầu) hoặc Home (đã dùng)

**Giao diện:**
```
┌─────────────────────────┐
│                         │
│    🐼 App Logo          │
│                         │
│      PandaEdu          │
│   Voice Flashcards     │
│                         │
│   ⭕ Loading...         │
│   "Đang tải dữ liệu..."│
│                         │
└─────────────────────────┘
```

---

### 2. 👋 **Onboarding Page** (`onboarding_page.dart`)
**Chức năng:**
- Hướng dẫn sử dụng app lần đầu
- Giới thiệu tính năng chính
- Nút "Bắt đầu" để vào app

**Giao diện:**
```
┌─────────────────────────┐
│   Chào mừng đến với    │
│      PandaEdu! 🐼      │
│                         │
│  [Minh họa tính năng]  │
│                         │
│  • Ghi âm giọng nói    │
│  • Tự động chuyển text │
│  • Học flashcard dễ dàng│
│                         │
│   [Nút: Bắt đầu]       │
└─────────────────────────┘
```

---

### 3. 🏠 **Home Page** (`home_page.dart`)
**Chức năng chính:**
- Hiển thị danh sách tất cả flashcards
- Tìm kiếm flashcard
- Sắp xếp: Mới nhất, Tên A-Z
- Nút mic lớn để tạo flashcard mới
- Nút vào trang Ôn tập
- Toggle Dark/Light mode
- Vào Settings

**Giao diện:**
```
┌─────────────────────────────────────┐
│ PandaEdu          [🎓] [⋮ Menu]    │
├─────────────────────────────────────┤
│ [🔍 Tìm kiếm flashcard...]  [⋮Sort]│
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🐼 Flashcard Title             │ │
│ │ Nội dung transcript...         │ │
│ │ 12/12/2024 10:30       [▶️]    │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 🐼 Another Flashcard           │ │
│ │ More content here...           │ │
│ │ 11/12/2024 09:15       [▶️]    │ │
│ └─────────────────────────────────┘ │
│                                     │
│           [🎤 FAB Button]           │
└─────────────────────────────────────┘
```

**Features:**
- ✅ Pull to refresh
- ✅ Tap vào card → Chi tiết
- ✅ Tap vào ▶️ → Play audio inline
- ✅ Empty state nếu chưa có flashcard
- ✅ Search real-time
- ✅ Sort options: Mới nhất, Tên A-Z

---

### 4. 🎤 **Record Page** (`record_page.dart`)
**Chức năng:**
- Ghi âm giọng nói
- Speech-to-Text real-time
- Hiển thị live transcript
- Yêu cầu quyền microphone
- Hiển thị thời gian ghi âm
- Animated panda khi đang ghi

**Giao diện:**
```
┌─────────────────────────────────────┐
│ ← Ghi âm                            │
├─────────────────────────────────────┤
│                                     │
│         🐼 Panda Mic               │
│        [Animated]                   │
│                                     │
│         00:05 / 01:00              │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Live Transcript:              │ │
│  │ "Đây là nội dung đang         │ │
│  │  được ghi âm và chuyển        │ │
│  │  thành text..."               │ │
│  └───────────────────────────────┘ │
│                                     │
│       [🔴 Stop Recording]           │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- ✅ Tap để bắt đầu/dừng ghi âm
- ✅ Real-time transcript hiển thị
- ✅ Timer countdown (max 60s)
- ✅ Tự động chuyển sang Confirm page sau khi dừng
- ✅ Xử lý quyền microphone

---

### 5. ✍️ **Confirm Transcript Page** (`confirm_transcript_page.dart`)
**Chức năng:**
- Xác nhận transcript sau ghi âm
- Chỉnh sửa title và transcript
- Nghe lại audio đã ghi
- Lưu flashcard

**Giao diện:**
```
┌─────────────────────────────────────┐
│ ← Xác nhận                    [💾] │
├─────────────────────────────────────┤
│                                     │
│  Tiêu đề:                          │
│  ┌───────────────────────────────┐ │
│  │ Nhập tiêu đề flashcard...     │ │
│  └───────────────────────────────┘ │
│                                     │
│  📢 Audio đã ghi:                  │
│  ┌───────────────────────────────┐ │
│  │ ▶️ [=========>    ] 00:05     │ │
│  └───────────────────────────────┘ │
│                                     │
│  Nội dung:                         │
│  ┌───────────────────────────────┐ │
│  │ Đây là transcript từ          │ │
│  │ speech-to-text. Có thể        │ │
│  │ chỉnh sửa nếu cần...          │ │
│  │                                │ │
│  └───────────────────────────────┘ │
│                                     │
│         [Lưu Flashcard]            │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- ✅ Validation: Tiêu đề và nội dung không được rỗng
- ✅ Audio player để nghe lại
- ✅ TextField để edit title & transcript
- ✅ Lưu vào database
- ✅ Quay về Home sau khi lưu

---

### 6. 📖 **Detail Page** (`detail_page.dart`)
**Chức năng:**
- Xem chi tiết flashcard
- Play audio
- Toggle favorite
- Xóa flashcard

**Giao diện:**
```
┌─────────────────────────────────────┐
│ ← Chi tiết            [♡] [⋮ Menu] │
├─────────────────────────────────────┤
│                                     │
│           🐼 Panda                  │
│                                     │
│                                     │
│   Flashcard Title Here              │
│                                     │
│                                     │
│  📢 Audio:                          │
│  ┌───────────────────────────────┐ │
│  │ ▶️ [=========>    ] 00:05     │ │
│  └───────────────────────────────┘ │
│                                     │
│  📝 Nội dung:                       │
│  ┌───────────────────────────────┐ │
│  │ Full transcript content       │ │
│  │ được hiển thị ở đây...        │ │
│  │                                │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- ✅ Favorite toggle (trái tim đỏ/trắng)
- ✅ Menu: Xóa flashcard (có confirm dialog)
- ✅ Audio player với progress bar
- ✅ Card UI đẹp mắt

---

### 7. 🎓 **Study Page** (`study_page.dart`)
**Chức năng:**
- Ôn tập flashcards
- Flip card để xem front/back
- Điều hướng: Quay lại / Tiếp theo
- Hiển thị progress
- Option học lại khi hoàn thành

**Giao diện:**
```
┌─────────────────────────────────────┐
│ ← Ôn tập Flashcards    [↻ Bắt đầu] │
├─────────────────────────────────────┤
│                                     │
│            3 / 10                   │
│        [=====>    ]                 │
│                                     │
│  ┌───────────────────────────────┐ │
│  │                                │ │
│  │      Flashcard Title          │ │
│  │                                │ │
│  │      [Tap to flip]            │ │
│  │                                │ │
│  └───────────────────────────────┘ │
│                                     │
│  [← Quay lại]     [Tiếp theo →]   │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- ✅ Flip animation khi tap vào card
- ✅ Progress bar & counter
- ✅ Nút "Quay lại" để xem thẻ trước
- ✅ Nút "Tiếp theo" để chuyển sang thẻ sau
- ✅ Nút "Bắt đầu lại" ở AppBar
- ✅ Dialog khi hoàn thành với options:
  - Về trang chủ
  - Học lại
- ✅ Hiển thị TẤT CẢ flashcards (không còn filter "due")
- ✅ Error handling nếu load thất bại

---

### 8. ⚙️ **Settings Page** (`settings_page.dart`)
**Chức năng:**
- Import/Export flashcards
- Xóa tất cả dữ liệu
- Thông tin app
- Backup & restore

**Giao diện:**
```
┌─────────────────────────────────────┐
│ ← Cài đặt                           │
├─────────────────────────────────────┤
│                                     │
│  📂 Dữ liệu                         │
│  ┌───────────────────────────────┐ │
│  │ 📤 Export Flashcards          │ │
│  ├───────────────────────────────┤ │
│  │ 📥 Import Flashcards          │ │
│  ├───────────────────────────────┤ │
│  │ 🗑️  Xóa tất cả dữ liệu        │ │
│  └───────────────────────────────┘ │
│                                     │
│  ℹ️ Thông tin                       │
│  ┌───────────────────────────────┐ │
│  │ Version: 1.0.0                │ │
│  │ Tổng flashcards: 25           │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- ✅ Export flashcards ra file JSON
- ✅ Import flashcards từ file
- ✅ Xóa tất cả (có confirm dialog)
- ✅ Hiển thị thông tin app

---

## 🧩 Widgets (Components)

### 1. **FlashcardTile** (`flashcard_tile.dart`)
- Card item hiển thị trong danh sách
- Panda thumbnail
- Title, transcript preview
- Ngày tạo
- Nút play audio

### 2. **FlipCardWidget** (`flip_card_widget.dart`)
- Card có thể flip 180°
- Front: Title
- Back: Transcript
- Smooth animation

### 3. **AudioPlayerWidget** (`audio_player_widget.dart`)
- Play/Pause button
- Progress slider
- Time display (current/total)
- Seek functionality

### 4. **LiveTranscriptView** (`live_transcript_view.dart`)
- Hiển thị transcript real-time
- Auto-scroll khi có text mới
- Animated text appearance

### 5. **PandaEmptyState** (`panda_empty_state.dart`)
- Hiển thị khi không có data
- Panda sad image
- Custom message
- Hướng dẫn người dùng

---

## 🎨 Theme & Design

### Color Palette (Matcha Theme)
```dart
- matchaLight:   #A8D5BA  // Xanh matcha nhạt
- matchaMedium:  #7FB899  // Xanh matcha vừa
- matchaDark:    #4A7C59  // Xanh matcha đậm
- matchaDeep:    #6BBF59  // Xanh matcha sâu
- milkWhite:     #F9FDF7  // Trắng sữa
- pandaBlack:    #2C2C2C  // Đen panda
- accentOrange:  #FF6F61  // Cam nhấn
- success:       #4CAF50  // Xanh lá
- error:         #D32F2F  // Đỏ lỗi
- warning:       #FFA726  // Cam cảnh báo
```

### UI Style
- ✅ Material Design
- ✅ Rounded corners (8-24px)
- ✅ Card-based layout
- ✅ Smooth animations
- ✅ Panda mascot illustrations
- ✅ Light & Dark mode support

---

## 🔧 Core Services

### 1. **SpeechService** (`speech_service.dart`)
- Khởi tạo speech-to-text
- Start/stop listening
- Handle partial/final results
- Language: Vietnamese

### 2. **AudioService** (`audio_service.dart`)
- Play/pause/stop audio
- Seek to position
- Get duration
- Stream position updates

### 3. **PermissionsService** (`permissions_service.dart`)
- Request microphone permission
- Check permission status
- Handle denied/restricted cases

---

## 📊 State Management

### Providers:
1. **FlashcardProvider** - Quản lý flashcards
2. **ThemeProvider** - Quản lý dark/light mode
3. **RecordSttProvider** - Quản lý recording & STT

---

## 💾 Data Storage

### SharedPreferences:
- Flashcards (JSON array)
- Theme preference
- Onboarding status

### File System:
- Audio files (.m4a/.aac)
- Stored in app directory

---

## 🌟 Tính năng nổi bật

### ✅ Đã có:
1. ✅ Ghi âm giọng nói
2. ✅ Speech-to-Text real-time (Vietnamese)
3. ✅ Tạo flashcard từ audio
4. ✅ Flip card animation
5. ✅ Audio playback
6. ✅ Search & sort flashcards
7. ✅ Import/Export JSON
8. ✅ Dark/Light mode
9. ✅ Favorite flashcards
10. ✅ Delete flashcards
11. ✅ Empty state handling
12. ✅ Error handling
13. ✅ Loading states
14. ✅ Responsive UI

### 🚀 Đơn giản hóa (Mới cập nhật):
- ❌ Bỏ Spaced Repetition (nextReviewAt, repeatLevel)
- ✅ Hiển thị TẤT CẢ flashcards trong Study
- ✅ Nút Quay lại/Tiếp theo thay vì Rating
- ✅ Option "Học lại" sau khi hoàn thành
- ✅ Nút "Bắt đầu lại" trong Study page

---

## 📱 Navigation Flow

```
Splash → Onboarding (first time) → Home
              ↓                      ↓
            Home ←──────────────────┘
              ↓
    ┌─────────┼─────────┐
    ↓         ↓         ↓
  Record   Study   Settings
    ↓         ↓         
  Confirm   Detail     
    ↓         
  Home      
```

---

## 🎯 Use Cases

### 1. Tạo flashcard mới:
```
Home → Tap [🎤] → Record → Confirm → Save → Home
```

### 2. Học flashcards:
```
Home → Tap [🎓] → Study → Flip cards → Next/Back → Complete
```

### 3. Xem chi tiết:
```
Home → Tap card → Detail → Play audio / Favorite / Delete
```

### 4. Tìm kiếm:
```
Home → Type in search → Filter real-time
```

### 5. Import/Export:
```
Home → Menu → Settings → Export/Import
```

---

## 📦 Dependencies

### Core:
- `flutter` - Framework
- `provider` - State management
- `shared_preferences` - Local storage

### Features:
- `speech_to_text` - STT engine
- `audioplayers` - Audio playback
- `permission_handler` - Permissions
- `file_picker` - Import/Export

### Utilities:
- `equatable` - Value equality
- `uuid` - ID generation
- `intl` - Internationalization

---

## 🐼 Mascot: Panda

### Panda States (Assets):
1. `panda_wave.png` - Chào mừng
2. `panda_happy.png` - Vui vẻ
3. `panda_sad.png` - Buồn (empty state)
4. `panda_mic.png` - Đang ghi âm
5. `panda_books.png` - Đang học
6. `panda_placeholder.png` - Default
7. `app_logo.png` - Logo app

---

## 🎨 Screens Summary

| Screen | Purpose | Key Features |
|--------|---------|--------------|
| Splash | Khởi động | Loading, preload data |
| Onboarding | Giới thiệu | First-time guide |
| Home | Trang chính | List, search, sort |
| Record | Ghi âm | STT, real-time |
| Confirm | Xác nhận | Edit, save |
| Study | Ôn tập | Flip card, navigate |
| Detail | Chi tiết | View, play, delete |
| Settings | Cài đặt | Import, export |

---

## ✨ Tổng kết

**PandaEdu** là một ứng dụng flashcard voice-based đơn giản, thân thiện, với:
- 🎤 8 màn hình chính
- 🧩 5 widgets tái sử dụng
- 🔧 3 core services
- 🎨 Matcha theme đẹp mắt
- 🐼 Panda mascot dễ thương
- ✅ Chức năng đầy đủ cho việc học tập

**Mục tiêu:** Tạo flashcards nhanh chóng bằng giọng nói, học mọi lúc mọi nơi! 🚀

