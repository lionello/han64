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
SCREEN_BASE	= VIC_BASE+$800	; Screen memory location
CHARSET1_BASE	= VIC_BASE+$000	; Custom character set location

VIC_BANK	= 3-(>VIC_BASE/$40)	; VIC bank number (0..3)
CHARSET1_BANK	= >(CHARSET1_BASE-VIC_BASE)/$8	; Character set bank number (0..3)
SCREEN_BANK	= >(SCREEN_BASE-VIC_BASE)/$4	; Screen memory bank number (0..3)

tmpptr	= $FB			; 2 bytes ZP: $FB/$FC
msgptr	= $FD			; Pointer into msg: $FD/$FE
tmp1	= $02
tmp2	= $FF

; Start of actual program
* = $0810

_start
	sei
	cld

; Change the VIC bank to Bank2: $8000-$BFFF
	lda CIA_VICBANK
	and #%11111100
	ora #VIC_BANK		; set bits 1..2 to 10 (Bank2)
	sta CIA_VICBANK

; Clear screen to spaces ($0 screen code) and set color = light gray ($0F)
	lda #$00
	ldx #$00
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

; Make space glyph
	lda #$00
	tax
	tay
	jsr CopyGlyph8

; Grab GB2312 chars from 'msg' and copy to custom charset
	lda #<msg
	sta msgptr
	lda #>msg
	sta msgptr+1
.nextchar
	ldy #1
	lda (msgptr),y		; Get GB2312 column byte
	tax
	dey
	lda (msgptr),y		; Get GB2312 row byte (or ASCII)
	beq .done		; End of text
	bpl +			; 0..127 ASCII => no 2nd byte
	inc msgptr		; Move to next byte (lo byte)
	bne +
	inc msgptr+1		; Move to next byte (hi byte)
+	inc msgptr		; Move to next byte (lo byte)
	bne +
	inc msgptr+1		; Move to next byte (hi byte)
+	cmp #$0A		; newline?
	beq .newline
	jsr GB2312_LookupGlyphID
	; A = glyph lo, X = glyph hi if found
	bcc .printchar

	; Check if glyph A/X is in cache
	sta tmp1		; save glyphID-lo
	clc
	adc #<cache1
	sta tmpptr		; tmpptr-lo = glyphID-lo + cache-lo
	txa
	adc #>cache1
	sta tmpptr+1		; tmpptr-hi = glyphID-hi + cache-hi + carry
	ldy #0
	lda (tmpptr),y
	bne .printchar		; non-zero => already cached

	lda next1		; destination character slot
	beq .printchar		; zero => wrapped around; don't overwrite cache
	sta (tmpptr),y		; store in cache
	tay			; Y = char slot
	lda tmp1		; load glyphID-lo
	jsr CopyGlyph8

	lda next1		; get char slot
	inc next1
.printchar:
	; Print character to screen
scr_lo = *+1
scr_hi = *+2
	sta SCREEN_BASE		; patched
	inc scr_lo
	bne .gotlo3
	inc scr_hi
	lda scr_hi
	cmp #$08
	beq .done
.gotlo3:
	dec col40
	bne .nextchar
	lda #40
	sta col40		; reset countdown
	jmp .nextchar

.newline:
	; Advance to start of next line
	; Just add col40 (remaining columns) to screen pointer
	lda col40
	clc
	adc scr_lo
	sta scr_lo
	bcc +
	inc scr_hi
+	lda scr_hi
	cmp #$08
	beq .done

	lda #40
	sta col40		; reset countdown
	jmp .nextchar

.done
; Sit in an infinite loop
.loop   jmp .loop

CopyGlyph8:
	; A = glyphID-lo, X = hi, Y = char slot
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
	lda #>CHARSET1_BASE/8	; always divisible by 8
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
-
src_lo = *+1
src_hi = *+2
	lda FONT8_BASE,y	; patched
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
	clc
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
next1:	!byte 1			; 0 = space, so start at 1
cache1:	!fill 5+2501		; glyphID cache (punctuation + 2501)
