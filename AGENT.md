# C64 Pinyin IME (GB2312, 2501 Glyphs)

A Mandarin Pinyin Input Method Editor for the Commodore 64, using a compact 7×7 bitmap font and GB2312-compatible encoding.

This project deliberately separates linguistic logic (pinyin) from encoding (GB2312) and rendering (glyphID) to keep the runtime simple, fast, and 6502-friendly.

## Scope (v1)

- 2501 Simplified Chinese characters
- 7×7 pixel bitmap font (7 bits per row, 7 bytes per glyph)
- Pinyin → single-character input (no dictionary / phrases yet)
- GB2312-compatible I/O
- ASCII + Hanzi text streams
- Offline table generation in Python
- Runtime lookup on C64 in 6502 assembly

## Core Architecture

```
Keyboard
  ↓
Pinyin parsing
  ↓
Initial / Ø bucket
  ↓
SyllableID
  ↓
Candidate glyphIDs
  ↓
Glyph bitmap (7×7)
  ↓
Screen
```

### Key Principles

- No Unicode at runtime
- Dense internal glyphID (0..2500)
- GB2312 used only for I/O
- All heavy processing offline

## Glyph Set

**Exactly 2501 Hanzi**

All are:

- GB2312 encodable
- BMP Unicode (no UTF-16 surrogates)

**Additional characters:**

- ~70 ASCII
- 8 GB2312 punctuation/symbols (rows 1–15)

### Glyph Storage

**font.bin**

Layout:

- glyphID × 7 bytes
- 1 byte per row, 7 bits used

## glyphID Ordering (Important)

**glyphID is assigned in GB2312 row/column order**

Why:

- Simplifies GB2312 encoding/decoding
- Enables reuse of a single glyphID → gb2312 table
- Improves locality when rendering text
- Avoids a second reverse-mapping table

Frequency is handled inside IME candidate ordering, not glyphID numbering.

## Encoding: GB2312

- **ASCII:** `0x00–0x7F`
- **Hanzi:** 2 bytes
  - lead: `0xA1–0xF7`
  - trail: `0xA1–0xFE`
- **Unused / invalid:** `0x80–0xA0`, `0xF8–0xFF`
- No BOM
- Stateless, streaming-friendly

GB2312 is strictly an I/O format, not used for internal logic.

## Pinyin Model

### Initial Buckets (24)

Canonical Hanyu Pinyin initials + Ø:

```
Ø
b p m f
d t n l
g k h
j q x
zh ch sh r
z c s
y w
```

- zh/ch/sh are atomic initials
- z ≠ zh, s ≠ sh, etc.
- Ø = vowel-initial syllables

### Vowel-Initial Handling

- Typing a vowel enters Ø bucket implicitly
- Apostrophe `'` forces Ø explicitly
- Matches real pinyin segmentation (xi'an)

### No Jianpin (yet)

- AQ → 安全 style abbreviation is not in v1
- Will be a separate phrase/dictionary layer later

## IME Tables (Binary)

Generated offline via Python.

### 1. glyph_gb2312.bin

**glyphID → GB2312 code (u16 LE)**

- Size: 2501 × 2 bytes

### 2. Syllable Tables (Level 1)

**syll_blob.bin**

```
[len][ascii bytes][len][ascii bytes]...
```

**syll_ptr.bin**

```
syllableID → offset into blob (u16)
```

**bucket.bin**

```
24 entries:
  [startID u16][count u16]
```

Syllables are sorted by (bucket, lexical) so each bucket is contiguous.

### 3. Pinyin → Characters (Level 2)

- syllableID → offset into py_idx (u16)
- syllableID → candidate count (u8)
- concatenated glyphID lists (u16 each)
- Candidates are initially sorted by GB2312 order for easy I/O
- Frequency sorting can be applied later

## Frequency Data (Optional, Recommended)

- Used to improve candidate ordering
- Applied offline
- Syllable candidates sorted by frequency rank

**Good sources:**

- SUBTLEX-CH (spoken / modern)
- Jun Da frequency list

## Unihan Source (Pinyin Data)

Authoritative pinyin mappings come from Unicode Unihan Database: `Unihan_Readings.txt` https://www.unicode.org/Public/UCD/latest/ucd/Unihan.zip

**Fields used:**

- `kMandarin` (baseline)
- tones stripped
- ü normalized to v

## Python Build Pipeline

**Inputs:**

- `chars.txt` (2501 Hanzi)
- `Unihan_Readings.txt`

All tables are included verbatim in assembly using `!binary`.

## Runtime (C64 / 6502)

- No UTF-8
- No Unicode
- No dynamic memory
- All tables are read-only
- Use a modern cross-assembler: cc65

**Lookup path:**

1. Parse input → initial/Ø
2. Get bucket range
3. Binary search syllable
4. Fetch candidate glyphIDs
5. Render font bitmap

## What This Is Not

- Not UTF-16
- Not Unicode runtime
- Not dictionary-based (yet)
- Not Traditional Chinese
- Not GBK/GB18030 runtime (but compatible offline)

## Future Work

- Phrase dictionary (2–4 chars)
- Jianpin mode
- MRU learning
- UTF-8 import/export

## Design Philosophy

- Structure beats cleverness
- Offline complexity, runtime simplicity
- Encoding ≠ language
- 6502 first, modern tooling second

## Text Rendering

- Text mode with custom charset(s)
- 40×25 characters

## IME Rendering

- Top line is IME input and candidate area
- Show max 10 candidates: `ying 1英 2婴 3鹰 4应 5营 6蝇 7迎 8赢 9盈 0影`
- Need next/prev page markers if >10 candidates
- Lower lines are normal text view area
- Cursor moves in text area, not IME area
