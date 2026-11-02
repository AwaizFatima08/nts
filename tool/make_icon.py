#!/usr/bin/env python3
"""Draws the launcher icon in code (flat shapes, no AI): deep green square with four answer-sheet
bubbles, the second one filled amber. Writes Android mipmaps, the Play icon and site images.

  python3 tool/make_icon.py
"""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
GREEN = (11, 93, 75)
AMBER = (227, 154, 28)
WHITE = (255, 255, 255)


def draw(size, rounded):
    s = 4 * size  # supersample for smooth edges
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if rounded:
        d.rounded_rectangle([0, 0, s - 1, s - 1], radius=int(s * 0.22), fill=GREEN)
    else:
        d.rectangle([0, 0, s, s], fill=GREEN)
    r, stroke = s * 0.105, int(s * 0.03)
    for i, cy in enumerate([0.235, 0.41, 0.59, 0.765]):
        y = s * cy
        filled = i == 1
        box = [s * 0.30 - r, y - r, s * 0.30 + r, y + r]
        d.ellipse(box, fill=AMBER if filled else None, outline=AMBER if filled else WHITE, width=stroke)
        d.rounded_rectangle([s * 0.48, y - s * 0.03, s * (0.80 if i % 2 == 0 else 0.72), y + s * 0.03], radius=int(s * 0.03), fill=WHITE)
    return img.resize((size, size), Image.LANCZOS)


def main():
    res = ROOT / "android/app/src/main/res"
    for folder, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        draw(px, rounded=True).save(res / f"mipmap-{folder}" / "ic_launcher.png")
    draw(512, rounded=False).convert("RGB").save(ROOT / "store-assets/icon-512.png")
    img = ROOT / "website/img"
    img.mkdir(exist_ok=True)
    draw(192, rounded=True).save(img / "icon.png")
    draw(48, rounded=True).save(img / "favicon.png")
    # Feature graphic: icon plus title.
    from PIL import ImageFont
    fg = Image.new("RGB", (1024, 500), GREEN)
    fg.paste(draw(240, rounded=True).convert("RGB"), (70, 130))
    d = ImageDraw.Draw(fg)
    bold = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 54)
    small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 30)
    d.text((350, 160), "Prep Simulator", font=bold, fill=WHITE)
    d.text((350, 224), "for NTS", font=bold, fill=WHITE)
    d.text((350, 305), "NAT · GAT · Recruitment mock tests", font=small, fill=(240, 220, 170))
    fg.save(ROOT / "store-assets/feature-graphic.png")
    print("icons written")


main()
