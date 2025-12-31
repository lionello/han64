#!/usr/bin/env python3
from pathlib import Path

from PIL import Image

SHEET_PNG = "sheet.png"
TILEMAP_TXT = "tilemap.txt"
OUT_FONT7 = "font7.bin"   # 7 bytes per glyph (rows 0..6)
OUT_FONT8 = "font8.bin"   # 8 bytes per glyph (rows 0..7)
OUT_GB2312 = "gb2312_chars.txt"  # for reference

TILE_W = 8
TILE_H = 8

# If your 7x7 lives at top-left of each 8x8 tile:
GLYPH_X0, GLYPH_Y0 = 0, 0   # offset inside tile
GLYPH_W,  GLYPH_H  = 7, 7   # active pixels
# If your margin is on the left/top instead, adjust offsets.

def load_tilemap(path: str) -> dict[str, tuple[int,int]]:
    """Return char -> (tile_row, tile_col) mapping."""
    lines = Path(path).read_text(encoding="utf-8").splitlines()
    m = {}
    for r, line in enumerate(lines):
        # Keep every codepoint; ignore whitespace entirely if needed
        chars = [ch for ch in line if ch not in (" ", "\t", "\r")]
        for c, ch in enumerate(chars):
            if ch in m:
                raise ValueError(f"duplicate char in tilemap: {ch} (U+{ord(ch):04X})")
            m[ch] = (r, c)
    return m

def bit_of(px: float | tuple[int, ...] | None) -> int:
    """Return 1 if pixel is 'on'. Works for RGB/RGBA/L modes."""
    if isinstance(px, float) or  isinstance(px, int) or px is None:
        r  = px or 0
    else:
        # px is tuple
        r = px[0]
    # treat dark as on; if your glyphs are white-on-black invert this
    return 1 if r < 128 else 0

def extract_glyph(img: Image.Image, tile_r: int, tile_c: int) -> tuple[bytes, bytes]:
    """
    Returns (glyph7, glyph8).
    Each row is a byte with MSB on the left (bit7..bit0).
    We only use bits 7..1 for 7px width; bit0 left 0.
    """
    x0 = tile_c * TILE_W + GLYPH_X0
    y0 = tile_r * TILE_H + GLYPH_Y0

    # Build 8 rows (pad row7 with 0 if you only have 7px height)
    rows8 = []
    for y in range(8):
        b = 0
        if y < GLYPH_H:
            for x in range(GLYPH_W):
                on = bit_of(img.getpixel((x0 + x, y0 + y)))
                if on:
                    b |= (1 << (7 - x))  # leftmost pixel -> bit7
        rows8.append(b)

    glyph8 = bytes(rows8)
    glyph7 = bytes(rows8[:7])
    return glyph7, glyph8

def main():
    img = Image.open(SHEET_PNG).convert("RGBA")
    w, h = img.size
    cols = w // TILE_W
    rows = h // TILE_H
    if cols * TILE_W != w or rows * TILE_H != h:
        raise ValueError(f"image size {w}x{h} not divisible by {TILE_W}x{TILE_H}")

    pos = load_tilemap(TILEMAP_TXT)

    # You want output in your glyphID order.
    # For now: sort by GB2312 bytes (matches earlier plan).
    chars = list(pos.keys())
    chars_hanzi = []
    for ch in chars:
        b = ch.encode("gb2312")
        if len(b) == 2 and 0xA1 <= b[0] <= 0xF7 and 0xA1 <= b[1] <= 0xFE and 16 <= (b[0] - 0xA0) <= 87:
            chars_hanzi.append(ch)

    if len(chars_hanzi) != 2501:
        raise ValueError(f"expected 2501 GB2312 Hanzi in tilemap, got {len(chars_hanzi)}")

    chars_hanzi.sort(key=lambda ch: ch.encode("gb2312"))  # glyphID order

    out7 = bytearray()
    out8 = bytearray()
    outGb = bytearray()

    for ch in chars_hanzi:
        tr, tc = pos[ch]
        g7, g8 = extract_glyph(img, tr, tc)
        out7.extend(g7)
        out8.extend(g8)
        outGb.extend(ch.encode("gb2312"))

    Path(OUT_FONT7).write_bytes(out7)
    Path(OUT_FONT8).write_bytes(out8)
    Path(OUT_GB2312).write_bytes(outGb)

    print("OK")
    print("glyphs:", len(chars_hanzi))
    print("font7 bytes:", len(out7), "expected", 2501 * 7)
    print("font8 bytes:", len(out8), "expected", 2501 * 8)

if __name__ == "__main__":
    main()