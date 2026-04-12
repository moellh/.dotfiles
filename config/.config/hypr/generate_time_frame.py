#!/usr/bin/env python3
"""
Generate hyprlock time animation frames.
Usage: python3 generate_time_frame.py <percent> <song_title> <output_path>
"""

import sys
import os
import random
import tempfile
from PIL import Image, ImageDraw


def generate_frame(percent: int, song_title: str, output_path: str, width: int = 2560, height: int = 1440):
    """Generate a frame with scattered dots based on song progress."""
    width, height = int(width), int(height)

    # Grid configuration - adaptive spacing based on resolution
    spacing = max(40, min(width, height) // 40)
    dot_size = spacing // 6
    cols = width // spacing
    rows = height // spacing

    total_dots = cols * rows

    # Create seed from song title only for deterministic randomness (so dots don't move)
    seed_str = f"{song_title}"
    random.seed(seed_str)

    # Create list of all dot positions and shuffle
    dot_positions = [(col, row) for row in range(rows) for col in range(cols)]
    random.shuffle(dot_positions)

    # Calculate how many dots should be "on"
    dots_on = int((percent * total_dots) / 100.0)
    dots_on = max(0, min(total_dots, dots_on))

    # Create transparent image
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))

    # Color: rgba(200, 220, 255, 0.5)
    dot_color = (200, 220, 255, 128)  # 0.5 * 255 = 128

    # Create a single anti-aliased dot mask (grayscale) by supersampling
    supersample = 4
    dot_image_size = (dot_size * 2 * supersample, dot_size * 2 * supersample)

    if dot_image_size[0] > 0 and dot_image_size[1] > 0:
        mask_large = Image.new('L', dot_image_size, 0)
        mask_draw = ImageDraw.Draw(mask_large)
        mask_draw.ellipse([0, 0, dot_image_size[0], dot_image_size[1]], fill=255)

        # Resize down to get anti-aliasing (LANCZOS)
        final_dot_size = (dot_size * 2, dot_size * 2)
        final_dot_size = (max(1, final_dot_size[0]), max(1, final_dot_size[1]))
        mask_small = mask_large.resize(final_dot_size, Image.Resampling.LANCZOS)

        # Scale the mask
        mask_small = mask_small.point(lambda p: p * 32 // 255)

        # Create the RGBA dot object with correct base color
        dot_img = Image.new('RGB', final_dot_size, (200, 220, 255))
        dot_img.putalpha(mask_small)

        # Draw active dots natively over transparent background via alpha compositing
        for i in range(dots_on):
            col, row = dot_positions[i]
            x = col * spacing + spacing // 2 - dot_size
            y = row * spacing + spacing // 2 - dot_size
            img.alpha_composite(dot_img, (x, y))

    # Save atomically: write to temp file first, then rename (avoids hyprlock reading partial PNG → SEGV)
    tmp_fd, tmp_path = tempfile.mkstemp(suffix='.png', dir=os.path.dirname(output_path))
    try:
        img.save(tmp_path, 'PNG')
        os.close(tmp_fd)
        os.replace(tmp_path, output_path)
    except Exception:
        try:
            os.close(tmp_fd)
        except OSError:
            pass
        try:
            os.unlink(tmp_path)
        except OSError:
            pass
        raise


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python3 generate_time_frame.py <percent> <song_title> <output_path>")
        sys.exit(1)

    percent = float(sys.argv[1])
    song_title = sys.argv[2]
    output_path = sys.argv[3]
    width = int(sys.argv[4]) if len(sys.argv) > 4 else 2560
    height = int(sys.argv[5]) if len(sys.argv) > 5 else 1440

    generate_frame(percent, song_title, output_path, width, height)
    print(output_path)
