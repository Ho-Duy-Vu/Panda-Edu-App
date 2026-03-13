"""
Simple Image Enhancement Script - Using AI Background Removal
==============================================================
Sử dụng rembg (AI-powered) để loại bỏ background tốt hơn

Cài đặt:
    pip install rembg[gpu] pillow pillow-avif-plugin opencv-python-headless

    Hoặc CPU only:
    pip install rembg pillow pillow-avif-plugin opencv-python-headless

Usage:
    python enhance_simple.py
"""

from rembg import remove
from PIL import Image, ImageEnhance, ImageFilter
import os
import io
from pathlib import Path

# Config
INPUT_DIR = "images"
OUTPUT_DIR = "images_enhanced"
MAX_SIZE = 1024
OUTPUT_FORMAT = "webp"
QUALITY = 95


def enhance_image(input_path, output_path):
    """Xử lý ảnh đơn giản"""
    print(f"📸 Processing: {input_path.name}")
    
    # 1. Đọc ảnh
    with open(input_path, 'rb') as f:
        input_data = f.read()
    
    # 2. Remove background (AI-powered - rất mạnh!)
    print("  🤖 Removing background with AI...")
    output_data = remove(input_data)
    
    # 3. Load image from bytes
    img = Image.open(io.BytesIO(output_data))
    
    # 4. Tăng độ nét
    print("  ✨ Sharpening...")
    img = img.filter(ImageFilter.UnsharpMask(radius=2, percent=150, threshold=3))
    
    sharpener = ImageEnhance.Sharpness(img)
    img = sharpener.enhance(1.5)
    
    # 5. Cân màu
    print("  🎨 Enhancing colors...")
    contrast = ImageEnhance.Contrast(img)
    img = contrast.enhance(1.2)
    
    color = ImageEnhance.Color(img)
    img = color.enhance(1.15)
    
    # 6. Resize nếu cần
    width, height = img.size
    max_dim = max(width, height)
    
    if max_dim > MAX_SIZE:
        print(f"  📏 Resizing from {img.size}...")
        scale = MAX_SIZE / max_dim
        new_size = (int(width * scale), int(height * scale))
        img = img.resize(new_size, Image.Resampling.LANCZOS)
    
    print(f"  📐 Final size: {img.size}")
    
    # 7. Save
    output_file = output_path / f"{input_path.stem}.{OUTPUT_FORMAT}"
    
    if OUTPUT_FORMAT == "webp":
        img.save(output_file, "WEBP", quality=QUALITY, method=6, lossless=False)
    else:
        img.save(output_file, "PNG", optimize=True)
    
    print(f"  ✅ Saved: {output_file.name}\n")


def main():
    input_dir = Path(INPUT_DIR)
    output_dir = Path(OUTPUT_DIR)
    output_dir.mkdir(exist_ok=True)
    
    print("=" * 60)
    print("🐼 PandaEdu Simple Image Enhancement (AI-Powered)")
    print("=" * 60)
    print(f"📁 Input:  {input_dir}")
    print(f"📁 Output: {output_dir}")
    print(f"📏 Max size: {MAX_SIZE}px")
    print(f"💾 Format: {OUTPUT_FORMAT.upper()}")
    print("=" * 60)
    print()
    
    # Get all PNG files
    images = list(input_dir.glob("*.png"))
    
    if not images:
        print("❌ Không tìm thấy ảnh PNG!")
        return
    
    print(f"Found {len(images)} images\n")
    
    for img_path in images:
        try:
            enhance_image(img_path, output_dir)
        except Exception as e:
            print(f"  ❌ Error: {e}\n")
    
    print("=" * 60)
    print("✅ DONE! Check folder:", output_dir)
    print("=" * 60)


if __name__ == "__main__":
    main()

