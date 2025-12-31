#!/usr/bin/env python3
from pathlib import Path

ROW_FIRST = 0xB0
ROW_LAST  = 0xD7          # inclusive, 40 rows
COL_FIRST = 0xA1
COL_LAST  = 0xFE          # inclusive, 94 cols

OFFSET = 1                # glyph ID offset (to account for special chars)
MISSING = 0xFF            # sentinel, rank must stay < 0x80

def extract_gb2312_codes_from_bytes(data: bytes):
    codes = []
    i = 0
    n = len(data)
    while i < n:
        b = data[i]
        if b < 0x80:
            i += 1
            continue
        if i + 1 >= n:
            break
        hi = b
        lo = data[i + 1]
        # GB2312 double-byte live in A1..FE (for both bytes)
        if 0xA1 <= hi <= 0xFE and 0xA1 <= lo <= 0xFE:
            codes.append((hi, lo))
        i += 2
    return codes

def gb_codes_from_files(paths):
    s = set()
    for p in paths:
        data = Path(p).read_bytes()
        for hi, lo in extract_gb2312_codes_from_bytes(data):
            s.add((hi, lo))
    return sorted(s)  # sorts by hi then lo, i.e. GB2312 order

def build_row_matrices(sorted_codes):
    """
    Builds 40 rows B0..D7.
    baseGlyphID is the global glyphID index in sorted_codes.
    cell[col] = rank-in-row (0..count-1) or 0xFF missing.
    """
    # map row -> list of lo bytes (sorted, unique)
    rows = {hi: [] for hi in range(ROW_FIRST, ROW_LAST + 1)}
    for gid, (hi, lo) in enumerate(sorted_codes):
        if ROW_FIRST <= hi <= ROW_LAST and COL_FIRST <= lo <= COL_LAST:
            rows[hi].append((lo, gid + OFFSET))

    out = {}
    for hi in range(ROW_FIRST, ROW_LAST + 1):
        entries = rows[hi]
        entries.sort(key=lambda x: x[0])
        count = len(entries)
        base = entries[0][1] if count else 0

        cells = [MISSING] * 94
        for rank, (lo, gid) in enumerate(entries):
            if rank >= 0x80:
                raise ValueError(f"Row {hi:02X} has {count} entries; rank {rank} overflows (<0x80 required).")
            col = lo - COL_FIRST
            if 0 <= col < 94:
                cells[col] = rank

        out[hi] = (base, cells, count)
    return out

def emit_asm(rows, out_path: str):
    def b(x): return f"${x:02X}"
    def wbytes(x): return f"${x & 0xFF:02X},${(x>>8)&0xFF:02X}"

    lines = []
    lines.append("; Auto-generated GB2312 row matrices for hi=$B0..$D7")
    lines.append("; Input: raw GB2312-encoded text files")
    lines.append("; Layout per row: .word baseGlyphID, then 94 bytes (rank 0..count-1) or $FF=missing")
    lines.append("; glyphID = baseGlyphID + rank")
    lines.append(f"; Missing sentinel = ${MISSING:02X} (rank must stay < $80 so BMI can detect missing)")
    lines.append("")

    for hi in range(ROW_FIRST, ROW_LAST + 1):
        base, cells, cnt = rows[hi]
        lines.append(f"; row hi={b(hi)} entries={cnt}")
        lines.append(f"gb_row_{hi:02X}:")
        lines.append(f"    !byte {wbytes(base)}")
        for i in range(0, 94, 16):
            chunk = cells[i:i+16]
            lines.append("    !byte " + ",".join(b(x) for x in chunk))
        lines.append("")

    Path(out_path).write_text("\n".join(lines))

if __name__ == "__main__":
    # Put your GB2312-encoded text files here:
    inputs = ["gb2312_chars.txt"]
    codes = gb_codes_from_files(inputs)
    rows = build_row_matrices(codes)
    emit_asm(rows, "gb40_rows.asm")
    print(f"Wrote gb40_rows.asm from {len(codes)} unique GB2312 codes")