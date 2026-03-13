"""
PandaEdu Image Enhancement Script
==================================
Xử lý ảnh tự động:
1. Loại bỏ nền caro/checkerboard
2. Tăng độ nét, super-resolution
3. Cân màu, ánh sáng, độ tương phản
4. Resize nếu cần (max 1024px)
5. Xuất WebP

Yêu cầu cài đặt:
    pip install Pillow pillow-avif-plugin opencv-python-headless numpy rembg

Usage:
    python enhance_images.py
"""

import os
from PIL import Image, ImageEnhance, ImageFilter
import cv2
import numpy as np
from pathlib import Path

# Configuration
INPUT_DIR = "images"
OUTPUT_DIR = "images_enhanced"
MAX_SIZE = 1024
OUTPUT_FORMAT = "webp"  # webp hoặc png
QUALITY = 95


def remove_checkerboard_bg(image):
    """
    Loại bỏ nền caro/checkerboard và giữ alpha channel
    """
    # Convert to numpy array
    img_array = np.array(image)
    
    # Nếu không có alpha channel, thêm vào
    if img_array.shape[2] == 3:
        # Tạo mask dựa trên màu checkerboard (thường là xám)
        # Checkerboard có pattern xám-trắng lặp lại
        gray = cv2.cvtColor(img_array, cv2.COLOR_RGB2GRAY)
        
        # Detect checkerboard pattern
        # Threshold để tìm các pixel có màu checkerboard
        # Checkerboard thường có các giá trị ~128 (xám) và ~255 (trắng)
        mask = np.ones(gray.shape, dtype=np.uint8) * 255
        
        # Tìm các pixel có pattern checkerboard
        checkerboard_gray = (gray > 180) | (gray < 150)
        mask[checkerboard_gray] = 0
        
        # Morphology operations để làm mịn mask
        kernel = np.ones((3, 3), np.uint8)
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
        
        # Blur mask để edge mịn hơn
        mask = cv2.GaussianBlur(mask, (5, 5), 0)
        
        # Add alpha channel
        img_rgba = cv2.cvtColor(img_array, cv2.COLOR_RGB2RGBA)
        img_rgba[:, :, 3] = mask
        
        return Image.fromarray(img_rgba)
    
    # Nếu đã có alpha channel, làm sạch nó
    alpha = img_array[:, :, 3]
    
    # Threshold alpha để loại bỏ semi-transparent checkerboard
    alpha_clean = np.where(alpha > 128, 255, 0).astype(np.uint8)
    
    # Morphology để làm mịn
    kernel = np.ones((3, 3), np.uint8)
    alpha_clean = cv2.morphologyEx(alpha_clean, cv2.MORPH_CLOSE, kernel)
    alpha_clean = cv2.morphologyEx(alpha_clean, cv2.MORPH_OPEN, kernel)
    
    # Gaussian blur cho edge mịn
    alpha_clean = cv2.GaussianBlur(alpha_clean, (5, 5), 0)
    
    img_array[:, :, 3] = alpha_clean
    
    return Image.fromarray(img_array)


def enhance_sharpness(image):
    """
    Tăng độ nét và super-resolution
    """
    # Unsharp mask để tăng độ nét
    enhanced = image.filter(ImageFilter.UnsharpMask(radius=2, percent=150, threshold=3))
    
    # Tăng sharpness
    sharpener = ImageEnhance.Sharpness(enhanced)
    enhanced = sharpener.enhance(1.5)
    
    # Detail enhancement
    enhanced = enhanced.filter(ImageFilter.DETAIL)
    
    return enhanced


def enhance_colors(image):
    """
    Cân màu, ánh sáng, độ tương phản
    """
    # Tăng độ tương phản
    contrast = ImageEnhance.Contrast(image)
    enhanced = contrast.enhance(1.2)
    
    # Tăng màu sắc
    color = ImageEnhance.Color(enhanced)
    enhanced = color.enhance(1.1)
    
    # Cân bằng brightness
    brightness = ImageEnhance.Brightness(enhanced)
    enhanced = brightness.enhance(1.05)
    
    return enhanced


def upscale_with_cv2(image):
    """
    Super-resolution sử dụng OpenCV
    """
    # Convert to numpy
    img_array = np.array(image)
    
    # Nếu có alpha channel, xử lý riêng
    has_alpha = img_array.shape[2] == 4
    if has_alpha:
        rgb = img_array[:, :, :3]
        alpha = img_array[:, :, 3]
        
        # Upscale RGB
        rgb_upscaled = cv2.detailEnhance(rgb, sigma_s=10, sigma_r=0.15)
        
        # Combine back
        result = np.dstack((rgb_upscaled, alpha))
    else:
        result = cv2.detailEnhance(img_array, sigma_s=10, sigma_r=0.15)
    
    return Image.fromarray(result)


def resize_if_needed(image, max_size=MAX_SIZE):
    """
    Resize nếu cạnh lớn nhất > max_size, giữ nguyên tỉ lệ
    """
    width, height = image.size
    max_dim = max(width, height)
    
    if max_dim > max_size:
        scale = max_size / max_dim
        new_width = int(width * scale)
        new_height = int(height * scale)
        
        # Sử dụng LANCZOS cho chất lượng cao
        return image.resize((new_width, new_height), Image.Resampling.LANCZOS)
    
    return image


def process_image(input_path, output_path):
    """
    Xử lý một ảnh
    """
    print(f"Processing: {input_path.name}")
    
    try:
        # Đọc ảnh
        img = Image.open(input_path)
        
        # Convert to RGBA nếu cần
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
        
        print(f"  - Original size: {img.size}")
        
        # 1. Loại bỏ nền caro
        print("  - Removing checkerboard background...")
        img = remove_checkerboard_bg(img)
        
        # 2. Upscale và enhance detail
        print("  - Upscaling and enhancing details...")
        img = upscale_with_cv2(img)
        
        # 3. Tăng độ nét
        print("  - Sharpening...")
        img = enhance_sharpness(img)
        
        # 4. Cân màu
        print("  - Enhancing colors...")
        img = enhance_colors(img)
        
        # 5. Resize nếu cần
        print("  - Resizing if needed...")
        img = resize_if_needed(img)
        
        print(f"  - Final size: {img.size}")
        
        # 6. Xuất file
        output_file = output_path / f"{input_path.stem}.{OUTPUT_FORMAT}"
        
        if OUTPUT_FORMAT == "webp":
            # WebP hỗ trợ alpha channel
            img.save(output_file, "WEBP", quality=QUALITY, method=6)
        else:
            img.save(output_file, "PNG", optimize=True)
        
        print(f"  ✅ Saved: {output_file.name}")
        
    except Exception as e:
        print(f"  ❌ Error: {e}")


def main():
    """
    Xử lý tất cả ảnh trong folder
    """
    # Tạo output directory
    input_dir = Path(INPUT_DIR)
    output_dir = Path(OUTPUT_DIR)
    output_dir.mkdir(exist_ok=True)
    
    print("=" * 50)
    print("PandaEdu Image Enhancement")
    print("=" * 50)
    print(f"Input: {input_dir}")
    print(f"Output: {output_dir}")
    print(f"Max size: {MAX_SIZE}px")
    print(f"Format: {OUTPUT_FORMAT.upper()}")
    print("=" * 50)
    print()
    
    # Lấy tất cả ảnh PNG
    image_files = list(input_dir.glob("*.png"))
    
    if not image_files:
        print("❌ Không tìm thấy ảnh PNG nào!")
        return
    
    print(f"Found {len(image_files)} images\n")
    
    # Xử lý từng ảnh
    for img_path in image_files:
        process_image(img_path, output_dir)
        print()
    
    print("=" * 50)
    print("✅ HOÀN THÀNH!")
    print(f"Check folder: {output_dir}")
    print("=" * 50)


if __name__ == "__main__":
    main()

