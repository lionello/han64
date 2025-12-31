; main.s (ACME)
; Build: acme main.s

; BASIC stub: 10 SYS 2064
* = $0801
	!byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

; Start of actual program
* = $0810

SCREEN  = $0400
COLOR   = $D800
VIC_BANK = $DD00  		; VIC bank register
VIC_MEMORY = $D018		; VIC memory control register
CHARSET_BANK = 6		; ($3000-$3FFF)
CHARSET_BASE = CHARSET_BANK*$800; Custom character set location

glyphid     = $FB          ; 2 bytes ZP: $FB/$FC
baseLo  = $02
baseHi  = $FF

_start
	sei
	cld

; Clear screen to spaces ($0 screen code) and set color = light gray ($0F)
	lda #$00
	ldx #$00
.clr1   sta SCREEN+$000,x
	sta SCREEN+$100,x
	sta SCREEN+$200,x
	sta SCREEN+$2E8,x         ; remainder (1000 bytes total)
	inx
	bne .clr1

	lda #$0F
	ldx #$00
.clr2   sta COLOR+$000,x
	sta COLOR+$100,x
	sta COLOR+$200,x
	sta COLOR+$2E8,x
	inx
	bne .clr2

; Set black background + border
	;lda #$00
	;sta $D021
	;sta $D020

;SHI=1+3260/2
;JIE=1+1740/2
;NI=1+2590/2
;HAO=1+1290/2

; Configure VIC-II to use custom character set
	lda VIC_MEMORY
	and #$F0		; clear character set bits
	ora #CHARSET_BANK*2	; set charset at $3000 (bank 6)
	sta VIC_MEMORY

msgptr = $FD	; Pointer into msg

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
	lda (msgptr), y		; Get GB2312 lo byte (column)
	tax
	dey
	lda (msgptr), y		; Get GB2312 hi byte (row or ASCII)
	beq .done		; End of text
	inc msgptr		; Move to next byte (lo byte)
	bne .gotlo
	inc msgptr+1		; Move to next byte (hi byte)
.gotlo:
	ora #0
	bpl .gotlo2		; Ignore ASCII for now
	inc msgptr		; Move to next byte (lo byte)
	bne .gotlo2
	inc msgptr+1		; Move to next byte (hi byte)
.gotlo2:
	jsr GB2312_LookupGlyphID
	; A = glyph lo, X = glyph hi if found

	; Check if in cache
	sta baseLo		; save glyphID-lo
	clc
	adc #<cache		; A = glyph-lo + cache-lo
	sta glyphid
	txa
	adc #>cache		; A = glyph-hi + cache-hi + carry
	sta glyphid+1
	ldy #0
	lda (glyphid),y
	bne .incache

	lda chrptr		; destination character slot
	beq .incache		; don't overwrite cache
	sta (glyphid), y	; store in cache
	tay			; Y = char slot
	lda baseLo		; load glyphID-lo
	jsr CopyGlyph8

	lda chrptr		; get char slot
	inc chrptr
.incache:
	; Print character to screen
scr:	sta SCREEN		; patched
	inc scr_lo
	bne .gotlo3
	inc scr_hi
	lda scr_hi
	cmp #$08
	beq .done
.gotlo3:
	jmp .nextchar

.done
; Sit in an infinite loop
.loop   jmp .loop

chrptr:	!byte 1			; 0 = space, so start at 1

cache:	!fill 2502		; glyphID cache (space + 2501)

scr_lo = scr+1
scr_hi = scr+2

CopyGlyph8:
	; A = glyphID-lo, X = hi, Y = char slot
	stx src_hi
	asl
	rol src_hi
	asl
	rol src_hi
	asl
	rol src_hi
	; Add FONT8_BASE
	clc			; should not be needed
	adc #<FONT8_BASE
	sta src_lo
	lda src_hi
	adc #>FONT8_BASE
	sta src_hi

	; Shift left 3 times (multiply by 8) with proper 16-bit handling
	lda #0
	sta dst_hi
	tya
	asl
	rol dst_hi
	asl
	rol dst_hi
	asl
	rol dst_hi
	sta dst_lo
	; Add CHARSET_BASE
	lda dst_hi
	clc
	adc #>CHARSET_BASE
	sta dst_hi

	ldy #7
.cp:
src:    lda FONT8_BASE,y     ; patched
dst:    sta CHARSET_BASE,y   ; patched
	dey
	bpl .cp
	rts

src_lo = src+1
src_hi = src+2
dst_lo = dst+1
dst_hi = dst+2

; ------------------------------------------------------------
; GB2312 -> glyphID lookup (rows $B0..$D7, 96 bytes per row)
; Row layout (generated):
;   !word baseGlyphID
;   !byte rank[94]      ; 0..count-1, $FF = missing (BMI)
;
; IN:
;   A = hi byte
;   X = lo byte
;
; OUT:
;   C=1 found: A=glyph lo, X=glyph hi
;   C=0 missing/out-of-range: A,X unchanged
;
; CLOBBERS: Y, glyphid, base
; ------------------------------------------------------------

GB2312_LookupGlyphID:
        ; hi in $B0..$D7?
        cmp #$B0
        bcc .miss
        cmp #$D8
        bcs .miss

        ; lo in $A1..$FE?
        cpx #$A1
        bcc .miss
        cpx #$FF
        bcs .miss

        ; row index = hi - $B0
        sec
        sbc #$B0
        tay

        ; glyphid = row base
        lda gb_row_ptr_lo,y
        sta glyphid
        lda gb_row_ptr_hi,y
        sta glyphid+1

        ; baseGlyphID
        ldy #0
        lda (glyphid),y
        sta baseLo
        iny
        lda (glyphid),y
        sta baseHi

        ; Y = col+2
        txa
        sec
        sbc #$A1            ; A = col (0..93)
        clc
        adc #2
        tay

        lda (glyphid),y         ; A = rank or $FF
        bmi .miss

        ; glyphID = base + rank
        clc
        adc baseLo          ; A = glyph lo
        pha
        lda baseHi
        adc #0
        tax                 ; X = glyph hi
        pla                 ; A = glyph lo
        sec                 ; found
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
	!byte 0

; Include 8x8 font data
FONT8_BASE	!byte 0,0,0,0,0,0,0,0	; space
		!binary "font8.bin"

!source "gb40_rows.asm"
