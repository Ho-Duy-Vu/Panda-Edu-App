# 🎨 PandaEdu Image Enhancement

## 🚀 Quick Start (Windows)

### Cách 1: Tự động (Khuyên dùng)
```
1. Double-click: run_enhancement.bat
2. Đợi xử lý xong
3. Check folder: images_enhanced/
```

### Cách 2: Manual
```bash
# Cài packages
pip install -r requirements.txt

# Chạy script
python enhance_simple.py
```

---

## 📁 Files trong folder này

```
pandaedu/assets/
├── images/                      📁 Ảnh gốc (7 files PNG)
├── images_enhanced/             📁 Ảnh đã xử lý (sẽ tự tạo)
├── enhance_simple.py           🐍 Script xử lý đơn giản (AI)
├── enhance_images.py           🐍 Script xử lý nâng cao
├── requirements.txt            📦 Python packages
├── run_enhancement.bat         🚀 Auto-run script (Windows)
├── IMAGE_ENHANCEMENT_GUIDE.md  📖 Hướng dẫn đầy đủ
└── README.md                   📄 File này
```

---

## ✅ Xử lý gì?

1. ✅ **Loại bỏ nền caro** (checkerboard) bằng AI
2. ✅ **Tăng độ nét** (sharpening + detail enhancement)
3. ✅ **Cân màu** (contrast + color + brightness)
4. ✅ **Resize** nếu > 1024px
5. ✅ **Xuất WebP** chất lượng cao

---

## 🎯 Kết quả

### Trước:
- ❌ PNG với nền caro
- ❌ Mờ, kém nét
- ❌ ~200KB/ảnh

### Sau:
- ✅ WebP transparent
- ✅ Rõ nét, sắc sảo
- ✅ ~30-50KB/ảnh

---

## 🔧 Tùy chỉnh

Edit `enhance_simple.py`:

```python
MAX_SIZE = 1024        # Kích thước max
OUTPUT_FORMAT = "webp" # "webp" hoặc "png"
QUALITY = 95           # 1-100
```

---

## 🆘 Gặp vấn đề?

### Lỗi: Python not found
```
→ Cài Python: https://www.python.org/
→ Tick "Add to PATH" khi cài
```

### Lỗi: pip install failed
```
→ Chạy CMD as Administrator
→ python -m pip install --upgrade pip
→ pip install -r requirements.txt
```

### Lỗi: rembg quá lâu
```
→ Lần đầu sẽ download AI model (~100MB)
→ Lần sau sẽ nhanh hơn
```

---

## 📚 Đọc thêm

- **IMAGE_ENHANCEMENT_GUIDE.md** - Hướng dẫn chi tiết
- **enhance_images.py** - Script nâng cao với nhiều options

---

## 🎉 Done!

Sau khi chạy xong:
1. Check folder `images_enhanced/`
2. Copy ảnh WebP về folder `images/`
3. Replace ảnh PNG cũ (hoặc giữ cả 2)
4. Flutter sẽ tự động dùng WebP nếu có

**Enjoy!** 🐼

