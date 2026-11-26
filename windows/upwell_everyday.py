#!/usr/bin/env python3
"""Upwell Everyday — 4K wallpapers with motivational quotes (macOS + Windows).

Every week it downloads 7 new 3840x2160 photos (Picsum / Unsplash photographers),
overlays a motivational quote on each, and sets today's one as your desktop wallpaper.

Usage:
  python upwell_everyday.py            # set today's wallpaper (fetches a new week if needed)
  python upwell_everyday.py --refresh  # force download of a fresh 7-day batch now
"""
import datetime as dt
import json
import os
import platform
import random
import subprocess
import sys
import textwrap
import urllib.request
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 3840, 2160
HOME = Path.home()
DATA = (Path(os.environ.get("APPDATA", HOME)) / "UpwellEveryday") if os.name == "nt" \
    else HOME / "Library" / "Application Support" / "UpwellEveryday"
WEEK_DIR = DATA / "week"
STATE = DATA / "state.json"

QUOTES = [
    ("The secret of getting ahead is getting started.", "Mark Twain"),
    ("It does not matter how slowly you go as long as you do not stop.", "Confucius"),
    ("Well done is better than well said.", "Benjamin Franklin"),
    ("What you do today can improve all your tomorrows.", "Ralph Marston"),
    ("Act as if what you do makes a difference. It does.", "William James"),
    ("Believe you can and you're halfway there.", "Theodore Roosevelt"),
    ("Do what you can, with what you have, where you are.", "Theodore Roosevelt"),
    ("Quality is not an act, it is a habit.", "Aristotle"),
    ("The journey of a thousand miles begins with one step.", "Lao Tzu"),
    ("Energy and persistence conquer all things.", "Benjamin Franklin"),
    ("Nothing will work unless you do.", "Maya Angelou"),
    ("Great things are done by a series of small things brought together.", "Vincent van Gogh"),
    ("Start where you are. Use what you have. Do what you can.", "Arthur Ashe"),
    ("Our greatest glory is not in never falling, but in rising every time we fall.", "Confucius"),
    ("You miss 100% of the shots you don't take.", "Wayne Gretzky"),
    ("The best way to predict the future is to create it.", "Peter Drucker"),
    ("Dream big and dare to fail.", "Norman Vaughan"),
    ("Small deeds done are better than great deeds planned.", "Peter Marshall"),
    ("If you're going through hell, keep going.", "Winston Churchill"),
    ("Success is the sum of small efforts, repeated day in and day out.", "Robert Collier"),
    ("Do one thing every day that scares you.", "Eleanor Roosevelt"),
    ("Happiness is not by chance, but by choice.", "Jim Rohn"),
    ("Discipline is the bridge between goals and accomplishment.", "Jim Rohn"),
    ("It always seems impossible until it's done.", "Nelson Mandela"),
    ("Keep your face always toward the sunshine.", "Walt Whitman"),
    ("Everything you've ever wanted is on the other side of fear.", "George Addair"),
    ("Hardships often prepare ordinary people for an extraordinary destiny.", "C.S. Lewis"),
    ("You are never too old to set another goal or to dream a new dream.", "C.S. Lewis"),
    ("Courage is grace under pressure.", "Ernest Hemingway"),
    ("With the new day comes new strength and new thoughts.", "Eleanor Roosevelt"),
    ("Perseverance is not a long race; it is many short races one after the other.", "Walter Elliot"),
    ("Opportunities don't happen. You create them.", "Chris Grosser"),
    ("Turn your wounds into wisdom.", "Oprah Winfrey"),
    ("The harder I work, the luckier I get.", "Samuel Goldwyn"),
    ("Don't watch the clock; do what it does. Keep going.", "Sam Levenson"),
]


def load_state():
    try:
        return json.loads(STATE.read_text())
    except Exception:
        return {}


def font(size, bold=False):
    candidates = [
        "/System/Library/Fonts/Supplemental/Georgia Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Georgia Italic.ttf",
        "/System/Library/Fonts/Supplemental/Georgia.ttf",
        "C:/Windows/Fonts/georgiab.ttf" if bold else "C:/Windows/Fonts/georgiai.ttf",
        "C:/Windows/Fonts/georgia.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "C:/Windows/Fonts/segoeui.ttf",
    ]
    for c in candidates:
        if os.path.exists(c):
            return ImageFont.truetype(c, size)
    return ImageFont.load_default(size)


def download_photo(seed: str) -> Image.Image:
    # Picsum serves Unsplash photographs cropped/resized to exactly 3840x2160 (4K UHD).
    url = f"https://picsum.photos/seed/{seed}/{W}/{H}.jpg"
    req = urllib.request.Request(url, headers={"User-Agent": "UpwellEveryday/1.0"})
    with urllib.request.urlopen(req, timeout=60) as r:
        tmp = WEEK_DIR / "_dl.jpg"
        tmp.write_bytes(r.read())
    img = Image.open(tmp).convert("RGB")
    if img.size != (W, H):
        img = img.resize((W, H), Image.LANCZOS)
    return img


def render(img: Image.Image, quote: str, author: str) -> Image.Image:
    # Darken a soft band in the centre so text is readable on any photo.
    overlay = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(overlay)
    d.rectangle([0, int(H * 0.30), W, int(H * 0.72)], fill=150)
    overlay = overlay.filter(ImageFilter.GaussianBlur(220))
    img = Image.composite(Image.new("RGB", (W, H), (0, 0, 0)), img, overlay)

    draw = ImageDraw.Draw(img)
    qf, af = font(132), font(72, bold=True)
    lines = textwrap.wrap(f"\u201c{quote}\u201d", width=34)
    line_h = 175
    y = H // 2 - (len(lines) * line_h) // 2 - 60
    for line in lines:
        tw = draw.textlength(line, font=qf)
        draw.text(((W - tw) / 2, y), line, font=qf, fill=(255, 255, 255),
                  stroke_width=3, stroke_fill=(0, 0, 0))
        y += line_h
    a = f"\u2014 {author}"
    aw = draw.textlength(a, font=af)
    draw.text(((W - aw) / 2, y + 50), a, font=af, fill=(235, 210, 150),
              stroke_width=2, stroke_fill=(0, 0, 0))
    return img


def build_week(start: dt.date):
    WEEK_DIR.mkdir(parents=True, exist_ok=True)
    for old in WEEK_DIR.glob("*.jpg"):
        old.unlink()
    state = load_state()
    used = set(state.get("used_quotes", []))
    pool = [q for q in QUOTES if q[0] not in used] or QUOTES[:]
    if len(pool) < 7:
        used, pool = set(), QUOTES[:]
    picks = random.sample(pool, 7)
    for i, (q, a) in enumerate(picks):
        day = start + dt.timedelta(days=i)
        seed = f"{day.isoformat()}-{random.randint(0, 10**9)}"
        print(f"Downloading 4K photo for {day} ...")
        img = render(download_photo(seed), q, a)
        img.save(WEEK_DIR / f"{day.isoformat()}.jpg", quality=93)
    (WEEK_DIR / "_dl.jpg").unlink(missing_ok=True)
    state["week_start"] = start.isoformat()
    state["used_quotes"] = sorted(used | {q for q, _ in picks})
    STATE.write_text(json.dumps(state, indent=2))


def set_wallpaper(path: Path):
    path = str(path.resolve())
    if platform.system() == "Darwin":
        script = f'tell application "System Events" to tell every desktop to set picture to POSIX file "{path}"'
        subprocess.run(["osascript", "-e", script], check=False)
    elif platform.system() == "Windows":
        import ctypes
        ctypes.windll.user32.SystemParametersInfoW(20, 0, path, 3)  # SPI_SETDESKWALLPAPER
    else:
        print("Unsupported OS; wallpaper saved at", path)


def main():
    today = dt.date.today()
    state = load_state()
    start = dt.date.fromisoformat(state["week_start"]) if "week_start" in state else None
    target = WEEK_DIR / f"{today.isoformat()}.jpg"
    if "--refresh" in sys.argv or start is None or (today - start).days >= 7 or not target.exists():
        build_week(today)
    # Copy to a unique filename each day so macOS notices the change.
    out = DATA / f"current-{today.isoformat()}.jpg"
    for old in DATA.glob("current-*.jpg"):
        if old != out:
            old.unlink()
    out.write_bytes(target.read_bytes())
    set_wallpaper(out)
    print("Wallpaper set:", out)


if __name__ == "__main__":
    main()
