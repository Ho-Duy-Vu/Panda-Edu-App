# Changelog - Đơn giản hóa chức năng học thẻ

## Ngày cập nhật: 2025-12-12

## Tóm tắt
Đã loại bỏ logic spaced repetition phức tạp, đơn giản hóa giao diện học thẻ, và thêm xử lý lỗi khi khởi động app.

---

## 🎯 Các thay đổi chính

### 1. ✅ Bỏ logic tính ngày học (Spaced Repetition)
**Files đã thay đổi:**
- `lib/domain/entities/flashcard.dart`
- `lib/data/models/flashcard_model.dart`

**Chi tiết:**
- Xóa fields: `nextReviewAt`, `repeatLevel`
- Flashcard giờ chỉ lưu thông tin cơ bản: id, title, transcript, audioPath, createdAt, favorite, duration

### 2. ✅ Cập nhật chức năng học thẻ
**Files đã thay đổi:**
- `lib/presentation/pages/study_page.dart`
- `lib/data/repositories/flashcard_repository_impl.dart`

**Thay đổi:**
- **Trước:** Chỉ hiển thị thẻ "đến hạn ôn" (based on nextReviewAt)
- **Sau:** Hiển thị TẤT CẢ thẻ flashcard
- **Bỏ:** Hệ thống rating (Khó/TB/Tốt) - không cần đánh giá độ khó
- **Thêm:** 
  - Nút "Quay lại" để xem lại thẻ trước đó
  - Nút "Bắt đầu lại" ở AppBar để reset về thẻ đầu tiên
  - Xử lý lỗi khi load thẻ
  - Dialog "Học lại" khi hoàn thành

### 3. ✅ Cập nhật FlashcardProvider
**File:** `lib/presentation/providers/flashcard_provider.dart`

**Thay đổi:**
- Bỏ method `updateReview()` (không còn cần update repeatLevel/nextReviewAt)
- Bỏ sort option `'due'` (vì không còn logic due date)
- Thêm error handling khi load flashcards thất bại

### 4. ✅ Cập nhật HomePage
**File:** `lib/presentation/pages/home_page.dart`

**Thay đổi:**
- Bỏ tùy chọn sắp xếp "Cần ôn" trong menu sort
- Chỉ còn: "Mới nhất" và "Tên A-Z"

### 5. ✅ Cải thiện DetailPage
**File:** `lib/presentation/pages/detail_page.dart`

**Thay đổi:**
- Bỏ hiển thị Chips: "Level X" và "Ôn: X ngày nữa"
- Giao diện giờ sạch sẽ hơn, chỉ hiển thị thông tin cần thiết
- Luôn hiển thị ảnh panda placeholder (không thay đổi theo level)

### 6. ✅ Thêm xử lý Loading/Error khi khởi động
**Files đã thay đổi:**
- `lib/main.dart`
- `lib/presentation/pages/splash_page.dart`

**Tính năng mới:**
- **main.dart:** Thêm ErrorApp widget để hiển thị lỗi nếu không thể khởi tạo SharedPreferences
- **splash_page.dart:**
  - Hiển thị trạng thái loading với message
  - Preload flashcards trong splash để đảm bảo data sẵn sàng
  - Hiển thị icon error và message nếu load thất bại
  - Tự động chuyển sang home page sau khi xử lý lỗi
  - Fallback an toàn nếu navigation thất bại

---

## 📱 Trải nghiệm người dùng mới

### Trước đây:
1. Vào trang Ôn tập → Chỉ thấy thẻ "đến hạn"
2. Xem thẻ → Rating Khó/TB/Tốt
3. Không thể quay lại thẻ trước
4. Xong thì... xong (không option học lại)

### Bây giờ:
1. Vào trang Ôn tập → Thấy TẤT CẢ thẻ flashcard
2. Xem thẻ → Nhấn "Tiếp theo" hoặc "Quay lại"
3. Có thể quay lại thẻ trước bất cứ lúc nào
4. Xong thì có option "Về trang chủ" hoặc "Học lại"
5. Có nút "Bắt đầu lại" ở góc AppBar

---

## 🔧 Migration Notes

### Dữ liệu cũ
Các flashcard đã lưu có `nextReviewAt` và `repeatLevel` sẽ:
- ✅ Vẫn load được (vì FlashcardModel.fromJson xử lý optional fields)
- ✅ Tự động bỏ qua các fields này khi đọc
- ✅ Khi save lại, sẽ không còn lưu 2 fields này nữa

### Breaking Changes
- ❌ Không thể sử dụng sort "Cần ôn" nữa
- ❌ Method `updateReview()` đã bị xóa
- ❌ Fields `nextReviewAt`, `repeatLevel` không còn tồn tại

---

## ✨ Kết quả

### Trước:
- 🔴 Logic phức tạp (spaced repetition)
- 🔴 Khó sử dụng (phải rating mỗi thẻ)
- 🔴 Không thể xem lại thẻ trước
- 🔴 Không xử lý lỗi khi load data

### Sau:
- ✅ Logic đơn giản (xem tất cả thẻ)
- ✅ Dễ sử dụng (chỉ cần nhấn Tiếp/Quay lại)
- ✅ Tự do điều hướng giữa các thẻ
- ✅ Xử lý lỗi tốt hơn khi khởi động app
- ✅ Có option học lại sau khi hoàn thành

---

## 🎉 Done!

App giờ nhẹ nhàng hơn, đơn giản hơn, và dễ sử dụng hơn! 🐼

