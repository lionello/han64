; main.asm (ACME)
; Build: acme main.asm

; BASIC stub: 10 SYS2064
* = $0801
    !word +, 10			; pointer to next line, line number 10
    !byte $9e			; SYS token
    !text "2064", $00		; address as string, then end-of-line
+   !word 0			; end of BASIC program

VIC_MEMORY	= $D018		; VIC memory control register
COLOR_BASE	= $D800
CIA_VICBANK	= $DD00  	; VIC bank register

VIC_BASE	= $8000
CHARSET1_BASE	= VIC_BASE+$0000	; Custom character set 1 (256 chars, 2KB)
CHARSET2_BASE	= VIC_BASE+$0800	; Custom character set 2 (256 chars, 2KB)
SCREEN_BASE	= VIC_BASE+$2000	; Screen memory location (1KB)

VIC_BANK	= >VIC_BASE/$40	; VIC bank number (0..3)
CHARSET1_BANK	= >(CHARSET1_BASE-VIC_BASE)/$8	; Character set bank number (0..7)
CHARSET2_BANK	= >(CHARSET2_BASE-VIC_BASE)/$8	; Character set 2 bank number (0..7)
SCREEN_BANK	= >(SCREEN_BASE-VIC_BASE)/$4	; Screen memory bank number (0..15)

tmpptr	= $FB			; 2 bytes ZP: $FB/$FC
msgptr	= $FD			; Pointer into msg: $FD/$FE
tmp1	= $02
tmp2	= $FF

CHARSET_SWITCH_ROW = 12		; Rows 0-11: charset1, rows 12-24: charset2

; Start of actual program
* = $0810

_start
	sei
	cld

; Change the VIC bank to Bank2: $8000-$BFFF
	lda CIA_VICBANK
	and #%11111100
	ora #3-VIC_BANK		; set bits 0..1
	sta CIA_VICBANK

; Clear screen to spaces ($0 screen code) and set color = light gray ($0F)
	lda #$00
	tax
-	sta SCREEN_BASE+$000,x
	sta SCREEN_BASE+$100,x
	sta SCREEN_BASE+$200,x
	sta SCREEN_BASE+$2E8,x	; remainder (1000 bytes total)
	inx
	bne -

; Set all colors to light gray
;	lda #$0F
;	ldx #$00
;-	sta COLOR_BASE$000,x
;	sta COLOR_BASE$100,x
;	sta COLOR_BASE$200,x
;	sta COLOR_BASE$2E8,x
;	inx
;	bne -

; Set black background + border
	;lda #$00
	;sta $D021
	;sta $D020

; Configure VIC-II to use custom character set
	lda VIC_MEMORY
	and #%00000001		; clear character set bits
	ora #CHARSET1_BANK*2	; set charset bank in bits 1..3
	ora #SCREEN_BANK*16	; set screen memory bank in bits 4..5
	sta VIC_MEMORY

; Clear caches
	lda #<cache1
	sta tmpptr
	lda #>cache1
	sta tmpptr+1
	jsr ClearCache
	lda #<cache2
	sta tmpptr
	lda #>cache2
	sta tmpptr+1
	jsr ClearCache

	jsr InitCharset

; Set up raster IRQ for charset switching
	lda #$7F
	sta $DC0D		; disable all CIA1 interrupts
	lda $DC0D		; acknowledge any pending
	lda #(50 + CHARSET_SWITCH_ROW * 8)  ; raster line for row 12
	sta $D012
	lda $D011
	and #$7F		; clear bit 7 for lines < 256
	sta $D011
	lda #$01		; enable raster interrupts
	sta $D01A
	lda #<RasterIRQ
	sta $0314
	lda #>RasterIRQ
	sta $0315
	cli

; Grab GB2312 chars from 'msg' and copy to custom charset
	lda #<msg
	sta msgptr
	lda #>msg
	sta msgptr+1

.loop
	jsr ReadChar
	cmp #$0A		; newline?
	beq .newline
	bcc .done		; non-printables

	jsr GB2312_LookupGlyphID
	; A = glyph lo, X = glyph hi, C=1 if found
	bcc .printchar		; not found => print space (glyph 0)

	sta tmp1		; save glyphID-lo
	stx tmp2		; save glyphID-hi
	; Choose cache based on current row
	ldy current_row
	cpy #CHARSET_SWITCH_ROW
	bcs .check_cache2

.check_cache1:
	; Check if glyph A/X is in cache1
	;clc			; should be clear from previous bcs
	adc #<cache1
	sta tmpptr		; tmpptr-lo = glyphID-lo + cache1-lo
	txa
	adc #>cache1
	sta tmpptr+1		; tmpptr-hi = glyphID-hi + cache1-hi + carry
	jmp +

.check_cache2:
	; Check if glyph A/X is in cache2
	clc
	adc #<cache2
	sta tmpptr		; tmpptr-lo = glyphID-lo + cache2-lo
	txa
	adc #>cache2
	sta tmpptr+1		; tmpptr-hi = glyphID-hi + cache2-hi + carry

+	ldy #0
	lda (tmpptr),y
	bne .printchar		; non-zero => already cached, A = char

	; Not cached, copy to cache, X = destination char slot
	lda next_char
	beq .cache_full		; 0 => wrapped around, cache full

	sta (tmpptr),y		; store char in cache
	pha			; save char slot for printing
	lda tmp1		; load glyphID-lo
	ldx tmp2		; load glyphID-hi
	jsr AddGlyph8
	pla			; A = char slot
	jmp .printchar

.cache_full:
	; Both caches full, show space (0); TODO: show placeholder

.printchar:
	; Print character to screen, A = char
	jsr PrintChar

-	lda current_row
	cmp #25
	bmi .loop

.done   jmp .done		; Sit in an infinite loop

.newline:
	jsr PrintNewLine
	jmp -

; ------------------------------------------------------------
; Print char in A to the screen and advance screen pointer
;
; IN: A = char
; CLOBBERS: A
; ------------------------------------------------------------
PrintChar:
scr_lo = *+1
scr_hi = *+2
	sta SCREEN_BASE		; patched
	inc scr_lo
	bne +
	inc scr_hi
+	dec col40
	beq .nextrow
	rts

; ------------------------------------------------------------
; Advance screen pointer to start of next line
;
; CLOBBERS: A
; ------------------------------------------------------------
PrintNewLine:
	; Add col40 (remaining columns) to screen pointer
	lda col40
	clc
	adc scr_lo
	sta scr_lo
	bcc +
	inc scr_hi
.nextrow:
+	lda #40
	sta col40		; reset countdown
	inc current_row		; advance to next row

	lda current_row
	cmp #CHARSET_SWITCH_ROW
	beq .select_charset2
	rts

.select_charset2:
	lda #>CHARSET2_BASE/8
	sta charset_bank
	;jmp InitCharset fall-through

; ------------------------------------------------------------
; Initialize the charset at charset_bank
; ------------------------------------------------------------
InitCharset:
	; Make space glyph
	lda #$00
	sta next_char
	tax
	jmp AddGlyph8

; ------------------------------------------------------------
; Clear CACHE_SIZE bytes at tmpptr (rounds up to full pages)
;
; IN: tmpptr = start address
; CLOBBERS: A, X, Y, tmpptr
; ------------------------------------------------------------
ClearCache:
	lda #0
	tay
	ldx #>(CACHE_SIZE+255)	; number of full pages (round up)
-	sta (tmpptr),y
	iny
	bne -
	inc tmpptr+1
	dex
	bne -
	rts

; ------------------------------------------------------------
; Read GB2312 char from msgptr into A/X and advance
;
; OUT:
;   A=row or ASCII, X=column
;
; CLOBBERS: Y=0
; ------------------------------------------------------------
ReadChar:
	ldy #1
	lda (msgptr),y		; Get GB2312 column byte
	tax
	dey
	lda (msgptr),y		; Get GB2312 row byte (or ASCII)
	bpl +			; 0..127 ASCII => no 2nd byte
	inc msgptr		; Move to next byte (lo byte)
	bne +
	inc msgptr+1		; Move to next byte (hi byte)
+	inc msgptr		; Move to next byte (lo byte)
	bne +
	inc msgptr+1		; Move to next byte (hi byte)
+	rts

; ------------------------------------------------------------
; Raster IRQ - Switch charset at row 12
; ------------------------------------------------------------
RasterIRQ:
	lda #$01
	sta $D019		; acknowledge raster interrupt

	lda $D012
	cmp #(50 + CHARSET_SWITCH_ROW * 8)
	bne .switch_back

.switch_to_charset2:
	lda VIC_MEMORY
	and #%11110001		; clear charset bits
	ora #(CHARSET2_BANK*2)	; set charset2
	sta VIC_MEMORY
	lda #250		; next IRQ near end of screen
	jmp +

.switch_back:
	lda VIC_MEMORY
	and #%11110001		; clear charset bits
	ora #CHARSET1_BANK*2	; set charset1
	sta VIC_MEMORY
	lda #(50 + CHARSET_SWITCH_ROW * 8)
+	sta $D012
	jmp $EA81		; KERNAL register restore + rti

; ------------------------------------------------------------
; Copy glyph in A/X to next free slot in charset_bank
;
; IN:
;   A = glyphID-lo, X = hi
;
; CLOBBERS: A, X, Y
; ------------------------------------------------------------
AddGlyph8:
	ldy next_char
	inc next_char
	; fall-through CopyGlyph8

; ------------------------------------------------------------
; Copy glyph in A/X to slot Y in charset_bank
;
; IN:
;   A = glyphID-lo, X = hi, Y = char slot
;
; CLOBBERS: A, X, Y
; ------------------------------------------------------------
CopyGlyph8:
	stx src_hi
	asl
	rol src_hi		; glyphID * 2
	asl
	rol src_hi		; glyphID * 4
	asl
	rol src_hi		; glyphID * 8
	; Add FONT8_BASE
	;clc			; should not be needed because last rol clears
	adc #<FONT8_BASE
	sta src_lo
	lda src_hi
	adc #>FONT8_BASE
	sta src_hi

	; Shift left 3 times (multiply by 8) with proper 16-bit handling
charset_bank = *+1
	lda #>CHARSET1_BASE/8	; always divisible by 8, patched
	sta dst_hi
	tya			; A = char slot
	asl
	rol dst_hi		; char slot * 2
	asl
	rol dst_hi		; char slot * 4
	asl
	rol dst_hi		; char slot * 8
	sta dst_lo

	ldy #7
src_lo = *+1
src_hi = *+2
-	lda FONT8_BASE,y	; patched
dst_lo = *+1
dst_hi = *+2
	sta CHARSET1_BASE,y	; patched
	dey
	bpl -
	rts

; ------------------------------------------------------------
; GB2312 -> glyphID lookup
; Handles:
;   - Hanzi rows $B0..$D7 (rank-based, checked first)
;   - Sparse characters (linear search fallback)
;
; IN:
;   A = hi byte
;   X = lo byte
;
; OUT:
;   C=1 found: A=glyph lo, X=glyph hi
;   C=0 missing: A=0, X=0
;
; CLOBBERS: Y, tmpptr, tmp1, tmp2
; ------------------------------------------------------------
GB2312_LookupGlyphID:
	; GB2312 row in $B0..$D7?
	cmp #$B0
	bcc .try_sparse   	; < $B0, try sparse characters
	cmp #$D8
	bcs .try_sparse   	; >= $D8, try sparse characters

	; row index = hi - $B0
	sec
	sbc #$B0
	tay
	; tmpptr = row base
	lda gb_row_ptr_lo,y
	sta tmpptr
	lda gb_row_ptr_hi,y
	sta tmpptr+1

	; baseGlyphID
	ldy #0
	lda (tmpptr),y
	sta tmp1
	iny
	lda (tmpptr),y
	sta tmp2

	; Y = col+2
	txa			; A = GB2312 column byte
	sec
	sbc #$A1-2		; Y = column index + skip baseGlyphID (2 bytes)
	bcc .miss		; < $A1 => not in hanzi
	tay
	lda (tmpptr),y		; A = rank or $FF
	bmi .miss		; $FF = not in 2501 hanzi

	; glyphID = baseGlyphID + rank
	clc
	adc tmp1		; A = glyph lo
	pha
	lda tmp2
	adc #0
	tax			; X = glyph hi
	pla			; A = glyph lo
	sec			; found
	rts
.try_sparse:
	; Linear search through sparse characters
	; A = GB2312 row byte, X = column byte
	sta tmp1		; save row byte
	ldy #0
.sparse_loop:
	lda gb_sparse_table,y
	beq .miss		; end of table, not found
	iny
	iny
	iny
	iny              	; skip 4 bytes to next entry
	cmp tmp1		; compare row
	bne .sparse_loop
	txa
	cmp gb_sparse_table+1-4,y	; compare column
	bne .sparse_loop
	lda gb_sparse_table+3-4,y	; glyphID hi
	tax
	lda gb_sparse_table+2-4,y	; glyphID lo
	sec			; found
	rts
.miss:
	ldx #$00
	lda #$00
	clc			; not found
	rts

; ------------------------------------------------------------
; 40 row pointers ($B0..$D7). Your generator must emit:
;   gb_row_B0: ... gb_row_B1: ... ... gb_row_D7:
; ------------------------------------------------------------

gb_row_ptr_lo:
	!byte <gb_row_B0,<gb_row_B1,<gb_row_B2,<gb_row_B3,<gb_row_B4
	!byte <gb_row_B5,<gb_row_B6,<gb_row_B7,<gb_row_B8,<gb_row_B9
	!byte <gb_row_BA,<gb_row_BB,<gb_row_BC,<gb_row_BD,<gb_row_BE
	!byte <gb_row_BF,<gb_row_C0,<gb_row_C1,<gb_row_C2,<gb_row_C3
	!byte <gb_row_C4,<gb_row_C5,<gb_row_C6,<gb_row_C7,<gb_row_C8
	!byte <gb_row_C9,<gb_row_CA,<gb_row_CB,<gb_row_CC,<gb_row_CD
	!byte <gb_row_CE,<gb_row_CF,<gb_row_D0,<gb_row_D1,<gb_row_D2
	!byte <gb_row_D3,<gb_row_D4,<gb_row_D5,<gb_row_D6,<gb_row_D7

gb_row_ptr_hi:
	!byte >gb_row_B0,>gb_row_B1,>gb_row_B2,>gb_row_B3,>gb_row_B4
	!byte >gb_row_B5,>gb_row_B6,>gb_row_B7,>gb_row_B8,>gb_row_B9
	!byte >gb_row_BA,>gb_row_BB,>gb_row_BC,>gb_row_BD,>gb_row_BE
	!byte >gb_row_BF,>gb_row_C0,>gb_row_C1,>gb_row_C2,>gb_row_C3
	!byte >gb_row_C4,>gb_row_C5,>gb_row_C6,>gb_row_C7,>gb_row_C8
	!byte >gb_row_C9,>gb_row_CA,>gb_row_CB,>gb_row_CC,>gb_row_CD
	!byte >gb_row_CE,>gb_row_CF,>gb_row_D0,>gb_row_D1,>gb_row_D2
	!byte >gb_row_D3,>gb_row_D4,>gb_row_D5,>gb_row_D6,>gb_row_D7

msg	!binary "chabuduo.bin"
	!byte 0				; null terminator, could be skipped because font starts with 0

; Include 8x8 font data
FONT8_BASE	!byte 0,0,0,0,0,0,0,0	; 0=space

		!byte %00000000		; 1=period (a1a3) 。
		!byte %00000000
		!byte %00000000
		!byte %00000000
		!byte %00100000
		!byte %01010000
		!byte %00100000
		!byte %00000000

		!byte %01000000		; 2=exclamation mark (a3a1) ！
		!byte %01000000
		!byte %01000000
		!byte %01000000
		!byte %01000000
		!byte %00000000
		!byte %01000000
		!byte %00000000

		!byte %00000000		; 3=comma (a3ac) ，
		!byte %00000000
		!byte %00000000
		!byte %00000000
		!byte %00100000
		!byte %00100000
		!byte %01000000
		!byte %00000000

		!byte %01100000		; 4=question mark (a3bf) ？
		!byte %10010000
		!byte %00010000
		!byte %00100000
		!byte %01000000
		!byte %00000000
		!byte %01000000
		!byte %00000000

		!binary "font8.bin"	; 5..2505

; ------------------------------------------------------------
; Sparse character lookup table
; - Manual entries (rows < $B0): not in tilemap, defined here
; - Generated entries (rows > $D7): appended from gb40_rows.asm
; ------------------------------------------------------------

gb_sparse_table:
	!byte $A1,$A3  ; 。(period)
	!word 1
	!byte $A3,$A1  ; ！(exclamation mark)
	!word 2
	!byte $A3,$AC  ; ，(comma)
	!word 3
	!byte $A3,$BF  ; ？(question mark)
	!word 4
	; Generated entries appended here, terminated by $00
!source "gb40_rows.asm"

col40:	!byte 40		; columns remaining until wrap (40..1)
current_row: !byte 0		; current screen row (0-24)
next_char: !byte 1		; next char in charset; 0 = space, so start at 1

CACHE_SIZE = 5+2501
cache1 = *			; glyphID -> cache1 slot mapping (right after program)
cache2 = $C000			; glyphID -> cache2 slot mapping
