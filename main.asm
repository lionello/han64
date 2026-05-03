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

CHARSET_SWITCH_ROW = 13		; Initia: rows 0-12 charset1, rows 13-24 charset2

; Start of actual program
* = $0810

_start
	sei
	cld

; Bank out BASIC ROM at $A000-$BFFF so screen RAM there is readable
; ($01 = $36: LORAM=0, HIRAM=1 keep KERNAL, CHAREN=1 keep I/O)
	lda #$36
	sta $01

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
	lda #(50 + CHARSET_SWITCH_ROW * 8)  ; raster line for switch row
	sta $D012
	sta irq_switch_line	; store for IRQ handler
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
	bne +
	jmp .newline
+	bcs +			; >= $0A, printable
	jmp .text_end		; null terminator / non-printables
+

	jsr GB2312_LookupGlyphID
	; A = glyph lo, X = glyph hi, C=1 if found
	bcc .printchar		; not found => print space (glyph 0)

	sta tmp1		; save glyphID-lo
	stx tmp2		; save glyphID-hi
	; B region: switch_row <= current_row < switch_row+13
	; A (above) and C (below) both render into TOP charset
	lda current_row
	sec
	sbc switch_row
	bcc .top_region		; current_row < switch_row → A region (TOP)
	cmp #13
	bcc .bot_region		; current_row - switch_row < 13 → B region (BOT)
.top_region:			; C region falls through here too
top_charset_val = *+1
	lda #>CHARSET1_BASE/8	; patched on swap
	sta charset_bank
	lda tmp1
	clc			; for adc below
.check_cache1:
top_cache_lo = *+1
	adc #<cache1		; patched on swap
	sta tmpptr
	txa
top_cache_hi = *+1
	adc #>cache1		; patched on swap
	sta tmpptr+1
	jmp +

.bot_region:
	lda bot_charset_val
	sta charset_bank
	lda tmp1
.check_cache2:
	clc
bot_cache_lo = *+1
	adc #<cache2		; patched on swap
	sta tmpptr
	txa
bot_cache_hi = *+1
	adc #>cache2		; patched on swap
	sta tmpptr+1

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
	jsr AddGlyph7
	pla			; A = char slot
	jmp .printchar

.cache_full:
	; Both caches full, show space (0); TODO: show placeholder

.printchar:
	; Print character to screen, A = char
	jsr PrintChar

-	lda current_row
	cmp #25
	bcc .loop		; < 25, keep rendering

	; Screen full — wait for user to scroll
	lda text_done
	bne .done		; no more text to display
	jsr WaitForSpace
	jsr ScrollScreen
	jsr AdjustSwitchRow

	; Set up to render into row 24
	lda #24
	sta current_row
	lda #<(SCREEN_BASE + 24*40)
	sta scr_lo
	lda #>(SCREEN_BASE + 24*40)
	sta scr_hi
	lda #40
	sta col40
	jmp .loop

.done	jmp .done		; Sit in an infinite loop

.text_end:
	lda #1
	sta text_done
	lda #25
	sta current_row		; force screen-full state
	jmp -			; go to scroll check → .done

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
	cmp #25
	bcs +			; off-screen, skip charset check
	cmp switch_row
	beq .select_charset2
+	rts

.select_charset2:
bot_charset_val = *+1
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
	jmp AddGlyph7

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
; Wait for SPACE key press and release
; ------------------------------------------------------------
WaitForSpace:
	lda #%01111111		; select keyboard row 7
	sta $DC00
-	lda $DC01
	and #%00010000		; bit 4 = SPACE
	bne -			; loop while not pressed
-	lda $DC01
	and #%00010000
	beq -			; loop while held
	rts

; ------------------------------------------------------------
; Scroll screen up by one row (40 bytes)
; Copy rows 1-24 to rows 0-23, clear row 24
; ------------------------------------------------------------
ScrollScreen:
	ldx #0
-	lda SCREEN_BASE+40,x
	sta SCREEN_BASE,x
	inx
	bne -
-	lda SCREEN_BASE+$100+40,x
	sta SCREEN_BASE+$100,x
	inx
	bne -
-	lda SCREEN_BASE+$200+40,x
	sta SCREEN_BASE+$200,x
	inx
	bne -
-	lda SCREEN_BASE+$300+40,x
	sta SCREEN_BASE+$300,x
	inx
	cpx #(1000-768-40)	; 192
	bne -
	; Clear row 24 to slot 0 (space)
	lda #0
	ldx #39
-	sta SCREEN_BASE+24*40,x
	dex
	bpl -
	rts

; ------------------------------------------------------------
; Adjust charset switch row after scroll
; Decrements switch_row, swaps charsets if it reaches 0
; ------------------------------------------------------------
AdjustSwitchRow:
	dec switch_row
	bne .update_irq
	; switch_row = 0: swap charset roles
	jmp SwapCharsets
.update_irq:
	; Compute raster line = 50 + switch_row * 8
	lda switch_row
	asl
	asl
	asl
	clc
	adc #50
	sta irq_switch_line
	sta $D012
	rts

; ------------------------------------------------------------
; Swap charset roles when switch_row reaches 0
; Visual boundary stays at row 13: pre-swap rows 0-12 were B (BOT),
; rows 13-24 were C (TOP). Post-swap they become A (TOP) and B (BOT)
; respectively, which lines up because TOP/BOT roles flip too.
; ------------------------------------------------------------
SwapCharsets:
	; Swap IRQ charset bits
	lda irq_top_bits
	ldx irq_bot_bits
	sta irq_bot_bits
	stx irq_top_bits

	; Swap cache pointers
	lda top_cache_lo
	ldx bot_cache_lo
	sta bot_cache_lo
	stx top_cache_lo
	lda top_cache_hi
	ldx bot_cache_hi
	sta bot_cache_hi
	stx top_cache_hi

	; Swap charset bank values (TOP/BOT roles flip)
	lda top_charset_val
	ldx bot_charset_val
	sta bot_charset_val
	stx top_charset_val

	; Set switch_row = 13: A=rows 0-12, B=rows 13-24, C=empty
	lda #CHARSET_SWITCH_ROW
	sta switch_row
	; IRQ at raster line 50 + 13*8 = 154
	lda #(50 + CHARSET_SWITCH_ROW * 8)
	sta irq_switch_line
	sta $D012
	rts

; ------------------------------------------------------------
; Raster IRQ - Two switches per frame: TOP→BOT at switch_row, BOT→TOP 13 rows later
; ------------------------------------------------------------
RasterIRQ:
	lda #$01
	sta $D019		; acknowledge raster interrupt

	lda $D012
irq_switch_line = *+1
	cmp #(50 + CHARSET_SWITCH_ROW * 8)  ; patched
	bne .switch_back

.switch_to_bot:
	lda VIC_MEMORY
	and #%11110001		; clear charset bits
irq_bot_bits = *+1
	ora #CHARSET2_BANK*2	; patched on swap
	sta VIC_MEMORY
	; second IRQ = irq_switch_line + 13 rows (104 lines), clamped to 250
	lda irq_switch_line
	clc
	adc #13*8
	bcc +
	lda #250		; clamp to end of visible area
+	jmp ++

.switch_back:
	lda VIC_MEMORY
	and #%11110001		; clear charset bits
irq_top_bits = *+1
	ora #CHARSET1_BANK*2	; patched on swap
	sta VIC_MEMORY
	lda irq_switch_line
++	sta $D012
	jmp $EA81		; KERNAL register restore + rti

; ------------------------------------------------------------
; Copy glyph in A/X to next free slot in charset_bank
;
; IN:
;   A = glyphID-lo, X = hi
;
; CLOBBERS: A, X, Y
; ------------------------------------------------------------
AddGlyph7:
	ldy next_char
	inc next_char
	; fall-through CopyGlyph7

; ------------------------------------------------------------
; Copy 7-byte glyph in A/X to slot Y in charset_bank
; (byte 7 assumed pre-zeroed in charset)
;
; IN:
;   A = glyphID-lo, X = hi, Y = char slot
;
; CLOBBERS: A, X, Y, tmp1, tmp2
; ------------------------------------------------------------
CopyGlyph7:
	sta tmp1		; save glyphID-lo for *7
	stx tmp2		; save glyphID-hi for *7
	stx src_hi
	asl
	rol src_hi		; glyphID * 2
	asl
	rol src_hi		; glyphID * 4
	asl
	rol src_hi		; glyphID * 8
	; Add FONT7_BASE
	;clc			; should not be needed because last rol clears
	adc #<FONT7_BASE
	sta src_lo
	lda src_hi
	adc #>FONT7_BASE
	sta src_hi
	; Subtract glyphID to get *7
	lda src_lo
	sec
	sbc tmp1
	sta src_lo
	lda src_hi
	sbc tmp2
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

	ldy #6
src_lo = *+1
src_hi = *+2
-	lda FONT7_BASE,y	; patched
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
FONT7_BASE	!byte 0,0,0,0,0,0,0	; 0=space

		!byte %00000000		; 1=period (a1a3) 。
		!byte %00000000
		!byte %00000000
		!byte %00000000
		!byte %00100000
		!byte %01010000
		!byte %00100000

		!byte %01000000		; 2=exclamation mark (a3a1) ！
		!byte %01000000
		!byte %01000000
		!byte %01000000
		!byte %01000000
		!byte %00000000
		!byte %01000000

		!byte %00000000		; 3=comma (a3ac) ，
		!byte %00000000
		!byte %00000000
		!byte %00000000
		!byte %00100000
		!byte %00100000
		!byte %01000000

		!byte %01100000		; 4=question mark (a3bf) ？
		!byte %10010000
		!byte %00010000
		!byte %00100000
		!byte %01000000
		!byte %00000000
		!byte %01000000

		!binary "font7.bin"	; 5..2505

		!byte %00000000		; 2506=em dash (a1aa) —
		!byte %00000000
		!byte %00000000
		!byte %11111111
		!byte %00000000
		!byte %00000000
		!byte %00000000

		!byte %00000000		; 2507=ellipsis (a1ad) …
		!byte %00000000
		!byte %00000000
		!byte %00000000
		!byte %00000000
		!byte %01010100
		!byte %00000000

		!byte %00010010		; 2508=left double quote (a1b0) “ U+201c
		!byte %00100100
		!byte %00100100
		!byte %00000000
		!byte %00000000
		!byte %00000000
		!byte %00000000

		!byte %01001000		; 2509=right double quote (a1b1) ” U+201d
		!byte %01001000
		!byte %10010000
		!byte %00000000
		!byte %00000000
		!byte %00000000
		!byte %00000000

		!byte %00000000		; 2510=fullwidth colon (a3ba) ：
		!byte %00100000
		!byte %00000000
		!byte %00000000
		!byte %00100000
		!byte %00000000
		!byte %00000000

		!byte %00000000		; 2511=fullwidth semicolon (a3bb) ；
		!byte %00100000
		!byte %00000000
		!byte %00000000
		!byte %00100000
		!byte %00100000
		!byte %01000000

; ------------------------------------------------------------
; Sparse character lookup table
; - Manual entries (rows < $B0): not in tilemap, defined here
; - Generated entries (rows > $D7): appended from gb40_rows.asm
; ------------------------------------------------------------

gb_sparse_table:
	!byte $A1,$A3  ; 。(period)
	!word 1
	!byte $A1,$AA  ; — (em dash)
	!word 2506
	!byte $A1,$AD  ; … (ellipsis)
	!word 2507
	!byte $A1,$B0  ; “ (left double quote)
	!word 2508
	!byte $A1,$B1  ; ” (right double quote)
	!word 2509
	!byte $A3,$A1  ; ！(exclamation mark)
	!word 2
	!byte $A3,$AC  ; ，(comma)
	!word 3
	!byte $A3,$BA  ; ：(fullwidth colon)
	!word 2510
	!byte $A3,$BB  ; ；(fullwidth semicolon)
	!word 2511
	!byte $A3,$BF  ; ？(question mark)
	!word 4
	; Generated entries appended here, terminated by $00
!source "gb40_rows.asm"

col40:		!byte 40	; columns remaining until wrap (40..1)
current_row:	!byte 0		; current screen row (0-24)
next_char:	!byte 1		; next char in charset; 0 = space, so start at 1
switch_row:	!byte CHARSET_SWITCH_ROW
text_done:	!byte 0		; 1 = no more text to render

CACHE_SIZE = 11+2501
cache1 = *			; glyphID -> cache1 slot mapping (right after program)
cache2 = $C000			; glyphID -> cache2 slot mapping
