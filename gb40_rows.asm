; Auto-generated GB2312 lookup tables
; Input: raw GB2312-encoded text files

; ------------------------------------------------------------
; Sparse character entries (rows > $D7, appended to gb_sparse_table)
; Format: [hi, lo, glyphID_lo, glyphID_hi] * N, terminated by $00
; ------------------------------------------------------------

gb_sparse_append:
    !byte $E3,$B6  ; GB2312 code
    !word $09C1      ; glyphID 2497
    !byte $E8,$EB  ; GB2312 code
    !word $09C2      ; glyphID 2498
    !byte $E9,$D9  ; GB2312 code
    !word $09C3      ; glyphID 2499
    !byte $F2,$BE  ; GB2312 code
    !word $09C4      ; glyphID 2500
    !byte $F2,$C7  ; GB2312 code
    !word $09C5      ; glyphID 2501
    !byte $F2,$D1  ; GB2312 code
    !word $09C6      ; glyphID 2502
    !byte $F2,$F0  ; GB2312 code
    !word $09C7      ; glyphID 2503
    !byte $F2,$F9  ; GB2312 code
    !word $09C8      ; glyphID 2504
    !byte $F6,$F9  ; GB2312 code
    !word $09C9      ; glyphID 2505
    !byte 0  ; end of table

; Generated sparse entries (rows > $D7): 9
; (Manual entries in main.asm handle rows < $B0)

; ------------------------------------------------------------
; GB2312 row matrices for hi=$B0..$D7
; Layout per row: .word baseGlyphID, then 94 bytes (rank 0..count-1) or $FF=missing
; glyphID = baseGlyphID + rank
; Missing sentinel = $FF (rank must stay < $80 so BMI can detect missing)
; ------------------------------------------------------------

; row hi=$B0 entries=61
gb_row_B0:
    !byte $05,$00
    !byte $00,$01,$02,$03,$04,$05,$06,$FF,$07,$FF,$08,$09,$0A,$0B,$FF,$FF
    !byte $0C,$0D,$0E,$0F,$10,$11,$FF,$12,$FF,$13,$FF,$14,$FF,$15,$FF,$FF
    !byte $16,$17,$FF,$18,$FF,$FF,$FF,$19,$1A,$FF,$1B,$FF,$1C,$1D,$FF,$FF
    !byte $1E,$FF,$1F,$20,$21,$22,$23,$24,$25,$26,$FF,$27,$28,$FF,$29,$2A
    !byte $2B,$FF,$2C,$2D,$2E,$2F,$30,$FF,$31,$32,$33,$34,$FF,$35,$36,$FF
    !byte $FF,$37,$FF,$38,$FF,$FF,$FF,$39,$FF,$FF,$3A,$3B,$FF,$3C

; row hi=$B1 entries=58
gb_row_B1:
    !byte $42,$00
    !byte $00,$FF,$01,$02,$03,$04,$05,$06,$07,$08,$FF,$09,$0A,$0B,$0C,$0D
    !byte $0E,$0F,$10,$11,$FF,$12,$FF,$13,$FF,$FF,$14,$15,$FF,$16,$FF,$17
    !byte $FF,$FF,$FF,$FF,$FF,$18,$19,$1A,$FF,$1B,$1C,$1D,$FF,$1E,$1F,$FF
    !byte $FF,$20,$FF,$FF,$21,$FF,$FF,$22,$23,$24,$25,$26,$FF,$27,$28,$29
    !byte $FF,$2A,$2B,$2C,$FF,$2D,$2E,$FF,$2F,$30,$FF,$FF,$31,$FF,$FF,$32
    !byte $FF,$FF,$FF,$FF,$33,$34,$FF,$35,$36,$37,$38,$FF,$39,$FF

; row hi=$B2 entries=64
gb_row_B2:
    !byte $7C,$00
    !byte $00,$01,$02,$FF,$03,$04,$FF,$05,$06,$07,$08,$FF,$FF,$09,$FF,$FF
    !byte $0A,$0B,$FF,$0C,$0D,$0E,$0F,$FF,$10,$FF,$11,$12,$13,$FF,$14,$FF
    !byte $15,$16,$17,$18,$19,$1A,$FF,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23
    !byte $FF,$24,$25,$26,$27,$28,$FF,$29,$2A,$FF,$2B,$2C,$2D,$FF,$2E,$2F
    !byte $30,$31,$32,$FF,$33,$34,$FF,$35,$36,$FF,$FF,$37,$FF,$38,$FF,$39
    !byte $3A,$FF,$FF,$FF,$FF,$FF,$FF,$3B,$FF,$3C,$3D,$3E,$3F,$FF

; row hi=$B3 entries=68
gb_row_B3:
    !byte $BC,$00
    !byte $00,$01,$02,$03,$04,$05,$06,$FF,$07,$08,$09,$0A,$0B,$FF,$0C,$FF
    !byte $0D,$0E,$0F,$10,$11,$12,$13,$FF,$14,$FF,$FF,$15,$FF,$16,$17,$FF
    !byte $18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$FF,$25,$26
    !byte $FF,$FF,$FF,$27,$FF,$28,$29,$2A,$2B,$FF,$2C,$FF,$2D,$FF,$2E,$2F
    !byte $30,$31,$FF,$32,$33,$34,$35,$FF,$36,$37,$FF,$FF,$FF,$38,$39,$3A
    !byte $3B,$3C,$3D,$3E,$3F,$40,$FF,$41,$FF,$FF,$FF,$FF,$42,$43

; row hi=$B4 entries=58
gb_row_B4:
    !byte $00,$01
    !byte $00,$01,$FF,$FF,$02,$03,$FF,$04,$05,$FF,$06,$07,$08,$09,$FF,$0A
    !byte $FF,$0B,$0C,$0D,$0E,$FF,$FF,$0F,$10,$11,$FF,$12,$13,$FF,$14,$FF
    !byte $FF,$FF,$FF,$FF,$15,$16,$17,$18,$19,$1A,$1B,$1C,$FF,$1D,$1E,$1F
    !byte $FF,$20,$21,$22,$23,$24,$FF,$FF,$25,$FF,$FF,$FF,$FF,$FF,$26,$27
    !byte $FF,$FF,$FF,$28,$29,$2A,$2B,$FF,$FF,$FF,$2C,$FF,$2D,$2E,$2F,$30
    !byte $FF,$31,$32,$33,$FF,$FF,$34,$35,$FF,$36,$FF,$37,$38,$39

; row hi=$B5 entries=63
gb_row_B5:
    !byte $3A,$01
    !byte $FF,$FF,$00,$01,$02,$FF,$FF,$03,$04,$05,$06,$FF,$07,$08,$09,$0A
    !byte $0B,$0C,$0D,$0E,$FF,$0F,$FF,$10,$11,$12,$FF,$13,$14,$15,$FF,$16
    !byte $17,$18,$19,$1A,$FF,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25
    !byte $26,$FF,$FF,$FF,$FF,$27,$28,$29,$FF,$2A,$2B,$2C,$2D,$FF,$2E,$FF
    !byte $FF,$FF,$2F,$30,$FF,$31,$32,$FF,$FF,$33,$FF,$FF,$34,$35,$FF,$FF
    !byte $36,$FF,$FF,$37,$38,$39,$3A,$3B,$3C,$FF,$3D,$FF,$FF,$3E

; row hi=$B6 entries=57
gb_row_B6:
    !byte $79,$01
    !byte $00,$01,$02,$03,$04,$FF,$FF,$05,$06,$07,$08,$09,$FF,$0A,$0B,$FF
    !byte $FF,$FF,$0C,$0D,$FF,$0E,$0F,$10,$11,$FF,$FF,$12,$13,$14,$FF,$15
    !byte $16,$17,$FF,$18,$19,$FF,$1A,$1B,$1C,$FF,$1D,$1E,$1F,$20,$21,$FF
    !byte $22,$FF,$23,$24,$FF,$25,$26,$27,$28,$FF,$FF,$29,$FF,$FF,$FF,$2A
    !byte $2B,$FF,$2C,$2D,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$2E,$2F,$30,$FF,$FF
    !byte $31,$FF,$FF,$FF,$FF,$32,$33,$34,$35,$36,$37,$FF,$FF,$38

; row hi=$B7 entries=72
gb_row_B7:
    !byte $B2,$01
    !byte $FF,$00,$01,$FF,$02,$03,$04,$05,$FF,$FF,$06,$07,$08,$FF,$FF,$FF
    !byte $09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$16,$17,$18
    !byte $19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$FF,$FF,$FF,$23,$24,$25
    !byte $26,$27,$FF,$FF,$FF,$28,$29,$2A,$FF,$FF,$2B,$2C,$2D,$FF,$2E,$2F
    !byte $30,$31,$32,$33,$34,$35,$36,$37,$FF,$38,$39,$3A,$FF,$3B,$3C,$3D
    !byte $3E,$3F,$FF,$40,$41,$42,$FF,$43,$44,$FF,$45,$46,$FF,$47

; row hi=$B8 entries=61
gb_row_B8:
    !byte $FA,$01
    !byte $00,$FF,$01,$FF,$02,$FF,$03,$04,$FF,$FF,$FF,$FF,$FF,$05,$06,$07
    !byte $08,$09,$0A,$0B,$0C,$0D,$FF,$0E,$0F,$10,$11,$FF,$12,$13,$FF,$FF
    !byte $FF,$FF,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$FF,$FF,$1D,$1E,$1F
    !byte $FF,$20,$FF,$FF,$21,$22,$23,$FF,$24,$25,$26,$FF,$FF,$FF,$27,$FF
    !byte $FF,$FF,$28,$FF,$29,$2A,$2B,$2C,$FF,$2D,$2E,$2F,$FF,$30,$31,$32
    !byte $33,$FF,$34,$35,$FF,$36,$37,$38,$39,$3A,$3B,$3C,$FF,$FF

; row hi=$B9 entries=67
gb_row_B9:
    !byte $37,$02
    !byte $FF,$FF,$FF,$00,$01,$02,$03,$FF,$04,$FF,$05,$06,$07,$08,$FF,$09
    !byte $0A,$0B,$0C,$0D,$0E,$FF,$0F,$FF,$10,$11,$12,$FF,$13,$14,$FF,$15
    !byte $FF,$16,$17,$18,$19,$FF,$1A,$1B,$1C,$1D,$1E,$1F,$FF,$20,$21,$FF
    !byte $FF,$22,$FF,$FF,$23,$24,$FF,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D
    !byte $2E,$2F,$30,$FF,$FF,$31,$FF,$32,$33,$34,$FF,$35,$36,$FF,$FF,$37
    !byte $38,$FF,$39,$FF,$FF,$3A,$3B,$3C,$3D,$3E,$3F,$40,$41,$42

; row hi=$BA entries=67
gb_row_BA:
    !byte $7A,$02
    !byte $FF,$00,$01,$FF,$FF,$02,$FF,$FF,$FF,$FF,$03,$04,$FF,$05,$06,$07
    !byte $08,$FF,$FF,$FF,$09,$FF,$FF,$FF,$0A,$0B,$FF,$0C,$0D,$FF,$FF,$0E
    !byte $0F,$FF,$10,$11,$12,$13,$14,$15,$16,$FF,$17,$FF,$18,$19,$1A,$1B
    !byte $FF,$FF,$1C,$FF,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25,$26,$27,$FF
    !byte $28,$29,$2A,$2B,$2C,$FF,$2D,$2E,$2F,$30,$FF,$31,$32,$33,$34,$35
    !byte $36,$37,$38,$39,$3A,$3B,$FF,$3C,$3D,$3E,$3F,$40,$41,$42

; row hi=$BB entries=61
gb_row_BB:
    !byte $BD,$02
    !byte $FF,$00,$FF,$01,$02,$FF,$03,$04,$05,$06,$FF,$07,$08,$09,$0A,$0B
    !byte $FF,$FF,$0C,$0D,$0E,$0F,$10,$FF,$11,$12,$13,$14,$15,$FF,$FF,$FF
    !byte $FF,$FF,$16,$17,$18,$19,$FF,$FF,$FF,$1A,$FF,$FF,$1B,$1C,$FF,$FF
    !byte $FF,$1D,$1E,$1F,$20,$21,$FF,$22,$23,$24,$25,$FF,$26,$FF,$FF,$FF
    !byte $27,$FF,$28,$FF,$FF,$29,$FF,$2A,$2B,$2C,$2D,$2E,$FF,$2F,$30,$31
    !byte $32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$FF,$FF,$3C,$FF

; row hi=$BC entries=65
gb_row_BC:
    !byte $FA,$02
    !byte $00,$01,$02,$03,$FF,$04,$FF,$05,$FF,$06,$07,$FF,$08,$09,$0A,$0B
    !byte $0C,$0D,$FF,$0E,$FF,$0F,$10,$11,$12,$13,$FF,$14,$FF,$15,$FF,$FF
    !byte $16,$FF,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$FF,$1F,$20,$21,$FF,$22
    !byte $23,$24,$25,$FF,$FF,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$FF,$2F
    !byte $30,$31,$FF,$32,$FF,$33,$34,$35,$FF,$FF,$FF,$36,$FF,$37,$FF,$FF
    !byte $FF,$38,$FF,$39,$3A,$FF,$FF,$3B,$3C,$FF,$3D,$3E,$3F,$40

; row hi=$BD entries=66
gb_row_BD:
    !byte $3B,$03
    !byte $00,$01,$02,$FF,$03,$FF,$FF,$04,$05,$06,$07,$08,$09,$0A,$0B,$FF
    !byte $0C,$0D,$0E,$FF,$0F,$FF,$FF,$10,$11,$12,$13,$14,$15,$16,$17,$18
    !byte $19,$FF,$FF,$FF,$1A,$FF,$1B,$FF,$FF,$FF,$FF,$1C,$FF,$1D,$1E,$1F
    !byte $FF,$20,$21,$22,$FF,$23,$24,$25,$26,$27,$FF,$28,$29,$FF,$2A,$2B
    !byte $2C,$2D,$2E,$2F,$FF,$FF,$30,$31,$32,$FF,$FF,$33,$34,$35,$36,$37
    !byte $38,$39,$FF,$3A,$3B,$3C,$FF,$3D,$FF,$3E,$3F,$40,$FF,$41

; row hi=$BE entries=57
gb_row_BE:
    !byte $7D,$03
    !byte $00,$01,$FF,$FF,$02,$03,$04,$05,$06,$07,$08,$FF,$09,$0A,$0B,$0C
    !byte $0D,$0E,$0F,$10,$11,$12,$FF,$FF,$13,$14,$15,$FF,$FF,$FF,$16,$17
    !byte $FF,$FF,$18,$FF,$19,$1A,$FF,$1B,$1C,$FF,$1D,$FF,$1E,$FF,$FF,$FF
    !byte $FF,$FF,$1F,$FF,$20,$21,$FF,$22,$23,$FF,$24,$25,$26,$27,$28,$29
    !byte $FF,$FF,$2A,$2B,$2C,$FF,$2D,$FF,$FF,$FF,$2E,$FF,$2F,$FF,$FF,$FF
    !byte $FF,$30,$FF,$FF,$31,$32,$FF,$33,$34,$35,$FF,$36,$37,$38

; row hi=$BF entries=51
gb_row_BF:
    !byte $B6,$03
    !byte $00,$FF,$FF,$FF,$FF,$FF,$FF,$01,$FF,$02,$FF,$FF,$03,$04,$05,$06
    !byte $FF,$FF,$07,$08,$09,$FF,$FF,$FF,$0A,$FF,$0B,$0C,$FF,$0D,$0E,$FF
    !byte $FF,$FF,$0F,$FF,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$FF
    !byte $FF,$FF,$1B,$FF,$1C,$1D,$1E,$1F,$FF,$20,$21,$FF,$22,$23,$FF,$24
    !byte $25,$26,$27,$28,$FF,$FF,$29,$FF,$2A,$FF,$FF,$2B,$2C,$2D,$FF,$FF
    !byte $2E,$FF,$2F,$FF,$FF,$30,$31,$FF,$FF,$FF,$32,$FF,$FF,$FF

; row hi=$C0 entries=60
gb_row_C0:
    !byte $E9,$03
    !byte $FF,$00,$01,$FF,$02,$FF,$03,$04,$05,$FF,$06,$07,$08,$09,$0A,$0B
    !byte $0C,$0D,$0E,$0F,$10,$11,$FF,$12,$13,$14,$FF,$15,$FF,$FF,$FF,$16
    !byte $17,$FF,$18,$19,$FF,$FF,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$FF
    !byte $FF,$FF,$FF,$FF,$23,$24,$25,$FF,$26,$FF,$27,$FF,$FF,$FF,$FF,$28
    !byte $29,$FF,$FF,$2A,$2B,$2C,$2D,$2E,$FF,$FF,$2F,$FF,$30,$31,$32,$33
    !byte $34,$35,$FF,$FF,$FF,$36,$37,$38,$FF,$39,$3A,$FF,$3B,$FF

; row hi=$C1 entries=64
gb_row_C1:
    !byte $25,$04
    !byte $FF,$00,$01,$FF,$02,$03,$04,$05,$06,$07,$08,$09,$FF,$0A,$0B,$FF
    !byte $0C,$FF,$0D,$0E,$0F,$10,$11,$12,$13,$14,$FF,$15,$16,$17,$18,$FF
    !byte $19,$FF,$FF,$1A,$1B,$1C,$FF,$FF,$1D,$FF,$1E,$FF,$FF,$FF,$1F,$20
    !byte $21,$22,$23,$24,$FF,$25,$26,$FF,$27,$28,$FF,$29,$FF,$FF,$FF,$FF
    !byte $2A,$FF,$2B,$2C,$2D,$FF,$2E,$2F,$30,$31,$32,$33,$34,$35,$36,$FF
    !byte $FF,$37,$FF,$38,$39,$3A,$3B,$3C,$3D,$3E,$FF,$FF,$3F,$FF

; row hi=$C2 entries=61
gb_row_C2:
    !byte $65,$04
    !byte $00,$01,$02,$FF,$03,$FF,$FF,$FF,$04,$FF,$05,$06,$FF,$FF,$07,$FF
    !byte $FF,$FF,$08,$FF,$09,$0A,$0B,$FF,$0C,$FF,$FF,$0D,$0E,$FF,$0F,$FF
    !byte $10,$FF,$11,$12,$FF,$FF,$13,$14,$15,$16,$17,$18,$FF,$FF,$FF,$FF
    !byte $19,$1A,$1B,$1C,$FF,$1D,$1E,$FF,$FF,$FF,$1F,$20,$21,$22,$23,$FF
    !byte $FF,$FF,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,$30,$31
    !byte $32,$33,$34,$35,$36,$37,$FF,$FF,$38,$39,$FF,$3A,$3B,$3C

; row hi=$C3 entries=62
gb_row_C3:
    !byte $A2,$04
    !byte $FF,$00,$01,$02,$FF,$03,$FF,$04,$05,$FF,$06,$07,$FF,$08,$09,$0A
    !byte $0B,$0C,$0D,$0E,$0F,$10,$11,$FF,$12,$13,$14,$15,$16,$FF,$17,$18
    !byte $FF,$FF,$19,$FF,$1A,$1B,$1C,$1D,$1E,$FF,$1F,$FF,$20,$21,$22,$FF
    !byte $FF,$FF,$FF,$23,$24,$25,$26,$27,$FF,$28,$29,$2A,$FF,$2B,$2C,$2D
    !byte $FF,$2E,$2F,$FF,$FF,$30,$31,$32,$FF,$FF,$33,$FF,$34,$35,$FF,$36
    !byte $37,$FF,$FF,$38,$FF,$FF,$39,$FF,$3A,$FF,$3B,$3C,$FF,$3D

; row hi=$C4 entries=64
gb_row_C4:
    !byte $E0,$04
    !byte $FF,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$FF,$0D
    !byte $0E,$FF,$0F,$10,$11,$12,$13,$14,$15,$FF,$16,$FF,$17,$18,$19,$FF
    !byte $1A,$1B,$1C,$1D,$FF,$1E,$1F,$20,$21,$FF,$22,$23,$24,$25,$26,$27
    !byte $28,$29,$FF,$2A,$2B,$2C,$FF,$2D,$FF,$2E,$2F,$30,$FF,$FF,$FF,$31
    !byte $32,$33,$34,$FF,$FF,$35,$FF,$FF,$FF,$36,$FF,$FF,$FF,$37,$38,$39
    !byte $3A,$3B,$3C,$FF,$FF,$FF,$FF,$FF,$FF,$3D,$FF,$FF,$3E,$3F

; row hi=$C5 entries=52
gb_row_C5:
    !byte $20,$05
    !byte $FF,$FF,$00,$01,$FF,$02,$FF,$03,$04,$05,$06,$07,$08,$09,$0A,$FF
    !byte $FF,$0B,$FF,$FF,$0C,$0D,$0E,$FF,$FF,$FF,$FF,$0F,$FF,$FF,$FF,$10
    !byte $11,$12,$FF,$13,$14,$15,$FF,$FF,$16,$17,$FF,$18,$FF,$19,$FF,$1A
    !byte $1B,$FF,$1C,$1D,$FF,$1E,$1F,$FF,$FF,$20,$FF,$21,$22,$FF,$23,$24
    !byte $FF,$25,$26,$27,$28,$FF,$29,$2A,$FF,$FF,$FF,$FF,$FF,$2B,$2C,$FF
    !byte $FF,$2D,$2E,$2F,$30,$31,$FF,$FF,$FF,$32,$33,$FF,$FF,$FF

; row hi=$C6 entries=64
gb_row_C6:
    !byte $54,$05
    !byte $FF,$00,$01,$02,$03,$FF,$FF,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C
    !byte $0D,$FF,$FF,$0E,$0F,$10,$11,$FF,$FF,$FF,$12,$13,$14,$15,$16,$17
    !byte $18,$19,$1A,$1B,$1C,$1D,$FF,$1E,$FF,$1F,$20,$21,$FF,$FF,$22,$FF
    !byte $23,$FF,$24,$FF,$25,$26,$27,$FF,$FF,$28,$29,$2A,$2B,$2C,$2D,$FF
    !byte $2E,$FF,$FF,$2F,$30,$31,$32,$FF,$FF,$FF,$33,$34,$FF,$FF,$35,$36
    !byte $37,$FF,$38,$39,$3A,$3B,$3C,$3D,$FF,$3E,$3F,$FF,$FF,$FF

; row hi=$C7 entries=55
gb_row_C7:
    !byte $94,$05
    !byte $00,$FF,$01,$FF,$FF,$02,$03,$04,$05,$FF,$06,$FF,$FF,$07,$FF,$08
    !byte $09,$0A,$0B,$FF,$FF,$FF,$0C,$FF,$0D,$FF,$0E,$FF,$0F,$FF,$10,$11
    !byte $FF,$FF,$12,$13,$14,$15,$16,$FF,$17,$FF,$FF,$FF,$FF,$FF,$FF,$18
    !byte $19,$1A,$FF,$1B,$FF,$1C,$1D,$1E,$1F,$20,$FF,$FF,$21,$FF,$FF,$22
    !byte $23,$24,$25,$FF,$26,$FF,$27,$FF,$28,$29,$2A,$2B,$FF,$2C,$2D,$2E
    !byte $FF,$2F,$30,$FF,$FF,$FF,$31,$32,$FF,$33,$34,$35,$36,$FF

; row hi=$C8 entries=63
gb_row_C8:
    !byte $CB,$05
    !byte $00,$01,$FF,$02,$03,$04,$FF,$05,$FF,$06,$07,$FF,$08,$09,$0A,$0B
    !byte $0C,$FF,$FF,$0D,$0E,$FF,$0F,$10,$11,$12,$13,$14,$FF,$15,$FF,$16
    !byte $FF,$17,$18,$19,$1A,$1B,$1C,$1D,$FF,$1E,$1F,$20,$FF,$21,$22,$FF
    !byte $FF,$FF,$23,$24,$25,$FF,$FF,$FF,$26,$27,$28,$29,$2A,$2B,$FF,$FF
    !byte $2C,$2D,$FF,$FF,$2E,$FF,$2F,$30,$31,$FF,$32,$FF,$33,$FF,$FF,$34
    !byte $35,$FF,$36,$37,$38,$39,$3A,$3B,$FF,$FF,$3C,$3D,$3E,$FF

; row hi=$C9 entries=61
gb_row_C9:
    !byte $0A,$06
    !byte $00,$01,$02,$03,$04,$FF,$FF,$05,$06,$FF,$07,$FF,$08,$09,$FF,$0A
    !byte $0B,$0C,$0D,$0E,$0F,$10,$FF,$FF,$11,$12,$FF,$13,$14,$FF,$FF,$15
    !byte $16,$17,$FF,$FF,$FF,$18,$FF,$19,$FF,$FF,$1A,$1B,$1C,$FF,$1D,$1E
    !byte $FF,$1F,$FF,$20,$21,$FF,$FF,$FF,$22,$23,$FF,$24,$FF,$FF,$25,$26
    !byte $27,$FF,$28,$29,$FF,$2A,$2B,$2C,$FF,$2D,$FF,$2E,$2F,$30,$FF,$FF
    !byte $31,$FF,$32,$33,$34,$35,$36,$37,$38,$39,$FF,$3A,$3B,$3C

; row hi=$CA entries=73
gb_row_CA:
    !byte $47,$06
    !byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$FF,$0C,$0D,$0E
    !byte $0F,$10,$11,$12,$13,$14,$15,$FF,$16,$FF,$17,$18,$19,$1A,$1B,$1C
    !byte $FF,$1D,$FF,$FF,$1E,$1F,$20,$FF,$FF,$21,$FF,$22,$23,$24,$25,$26
    !byte $FF,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,$30,$31,$32,$33,$34,$35
    !byte $FF,$36,$37,$38,$39,$3A,$FF,$3B,$3C,$FF,$FF,$3D,$3E,$3F,$FF,$40
    !byte $FF,$FF,$41,$42,$43,$44,$45,$46,$FF,$47,$FF,$FF,$48,$FF

; row hi=$CB entries=64
gb_row_CB:
    !byte $90,$06
    !byte $FF,$00,$01,$02,$03,$04,$05,$FF,$FF,$06,$07,$08,$09,$0A,$0B,$0C
    !byte $FF,$0D,$0E,$FF,$0F,$FF,$FF,$FF,$10,$11,$FF,$12,$13,$14,$15,$16
    !byte $FF,$17,$FF,$18,$FF,$19,$1A,$FF,$1B,$1C,$FF,$1D,$1E,$1F,$FF,$FF
    !byte $20,$21,$FF,$FF,$22,$FF,$23,$24,$25,$FF,$FF,$26,$FF,$27,$28,$29
    !byte $2A,$2B,$2C,$2D,$FF,$2E,$FF,$2F,$30,$31,$32,$33,$FF,$FF,$34,$35
    !byte $36,$FF,$FF,$FF,$37,$FF,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F

; row hi=$CC entries=58
gb_row_CC:
    !byte $D0,$06
    !byte $FF,$FF,$FF,$00,$01,$FF,$02,$03,$04,$FF,$05,$06,$FF,$FF,$07,$08
    !byte $FF,$09,$0A,$FF,$FF,$0B,$FF,$0C,$0D,$FF,$FF,$0E,$0F,$10,$11,$12
    !byte $13,$FF,$14,$FF,$FF,$15,$16,$FF,$17,$FF,$18,$FF,$19,$1A,$FF,$FF
    !byte $1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25,$FF,$26,$FF,$27,$FF
    !byte $28,$29,$2A,$2B,$2C,$2D,$FF,$FF,$FF,$FF,$FF,$2E,$2F,$30,$31,$32
    !byte $FF,$FF,$FF,$33,$34,$FF,$FF,$35,$36,$37,$FF,$38,$39,$FF

; row hi=$CD entries=66
gb_row_CD:
    !byte $0A,$07
    !byte $FF,$00,$01,$02,$03,$04,$05,$06,$07,$FF,$FF,$08,$09,$FF,$0A,$0B
    !byte $FF,$0C,$0D,$0E,$0F,$10,$11,$12,$FF,$FF,$13,$14,$15,$16,$17,$18
    !byte $19,$1A,$1B,$FF,$1C,$1D,$FF,$1E,$FF,$FF,$1F,$20,$FF,$FF,$21,$22
    !byte $23,$FF,$FF,$FF,$24,$FF,$25,$26,$27,$28,$29,$2A,$FF,$2B,$2C,$FF
    !byte $2D,$2E,$FF,$2F,$30,$31,$32,$33,$FF,$34,$35,$36,$37,$FF,$FF,$FF
    !byte $FF,$38,$FF,$39,$3A,$3B,$FF,$3C,$3D,$3E,$3F,$40,$FF,$41

; row hi=$CE entries=61
gb_row_CE:
    !byte $4C,$07
    !byte $FF,$00,$01,$FF,$02,$FF,$03,$04,$05,$06,$FF,$07,$FF,$08,$09,$0A
    !byte $0B,$0C,$0D,$0E,$FF,$0F,$FF,$10,$11,$12,$13,$FF,$14,$FF,$15,$16
    !byte $FF,$17,$18,$19,$1A,$1B,$1C,$1D,$FF,$1E,$FF,$1F,$FF,$FF,$FF,$FF
    !byte $20,$21,$FF,$22,$23,$24,$FF,$FF,$FF,$25,$26,$FF,$27,$28,$FF,$FF
    !byte $29,$2A,$FF,$2B,$2C,$FF,$2D,$2E,$2F,$FF,$FF,$FF,$30,$FF,$31,$FF
    !byte $32,$33,$34,$FF,$35,$36,$37,$FF,$FF,$38,$39,$3A,$3B,$3C

; row hi=$CF entries=73
gb_row_CF:
    !byte $89,$07
    !byte $00,$01,$02,$03,$04,$05,$06,$FF,$FF,$07,$FF,$FF,$FF,$08,$09,$0A
    !byte $0B,$0C,$FF,$0D,$0E,$0F,$10,$11,$12,$13,$FF,$14,$15,$FF,$16,$FF
    !byte $17,$18,$19,$1A,$1B,$1C,$FF,$1D,$1E,$1F,$20,$21,$22,$23,$FF,$24
    !byte $FF,$25,$26,$27,$28,$29,$2A,$2B,$2C,$FF,$FF,$2D,$2E,$2F,$30,$31
    !byte $32,$FF,$33,$34,$FF,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F
    !byte $40,$41,$42,$43,$44,$FF,$45,$FF,$FF,$46,$47,$FF,$FF,$48

; row hi=$D0 entries=67
gb_row_D0:
    !byte $D2,$07
    !byte $00,$01,$02,$FF,$FF,$03,$04,$FF,$05,$06,$FF,$07,$08,$FF,$09,$FF
    !byte $0A,$0B,$0C,$0D,$0E,$0F,$10,$FF,$11,$12,$13,$14,$FF,$FF,$FF,$15
    !byte $16,$17,$FF,$18,$19,$FF,$1A,$FF,$1B,$FF,$1C,$1D,$1E,$1F,$FF,$20
    !byte $21,$22,$23,$24,$25,$26,$27,$28,$29,$FF,$2A,$2B,$2C,$2D,$2E,$2F
    !byte $30,$FF,$31,$32,$33,$FF,$FF,$34,$35,$FF,$36,$37,$38,$39,$FF,$3A
    !byte $FF,$3B,$3C,$FF,$FF,$FF,$3D,$3E,$FF,$FF,$3F,$40,$41,$42

; row hi=$D1 entries=58
gb_row_D1:
    !byte $15,$08
    !byte $00,$FF,$FF,$FF,$FF,$FF,$01,$02,$03,$04,$FF,$FF,$05,$FF,$06,$07
    !byte $FF,$08,$FF,$FF,$09,$0A,$FF,$0B,$0C,$FF,$0D,$0E,$0F,$FF,$10,$11
    !byte $FF,$12,$FF,$FF,$13,$14,$15,$FF,$FF,$16,$FF,$17,$18,$19,$1A,$1B
    !byte $FF,$1C,$1D,$1E,$1F,$FF,$20,$21,$FF,$22,$23,$24,$25,$26,$FF,$27
    !byte $28,$FF,$29,$FF,$FF,$2A,$2B,$FF,$2C,$FF,$2D,$FF,$FF,$2E,$2F,$FF
    !byte $FF,$30,$31,$32,$33,$34,$35,$36,$37,$FF,$38,$39,$FF,$FF

; row hi=$D2 entries=60
gb_row_D2:
    !byte $4F,$08
    !byte $00,$FF,$01,$FF,$FF,$FF,$02,$FF,$03,$04,$05,$FF,$FF,$FF,$06,$07
    !byte $08,$09,$0A,$FF,$0B,$0C,$FF,$FF,$0D,$0E,$0F,$FF,$10,$FF,$FF,$11
    !byte $12,$13,$FF,$14,$15,$16,$17,$FF,$18,$FF,$19,$1A,$FF,$1B,$1C,$FF
    !byte $1D,$1E,$1F,$20,$21,$22,$23,$FF,$FF,$24,$25,$FF,$26,$FF,$27,$28
    !byte $FF,$29,$2A,$2B,$2C,$2D,$2E,$FF,$2F,$30,$31,$32,$33,$FF,$FF,$FF
    !byte $FF,$34,$FF,$35,$36,$FF,$37,$38,$FF,$FF,$39,$FF,$3A,$3B

; row hi=$D3 entries=61
gb_row_D3:
    !byte $8B,$08
    !byte $00,$01,$FF,$02,$03,$04,$FF,$FF,$FF,$05,$FF,$06,$07,$08,$09,$0A
    !byte $FF,$0B,$0C,$0D,$0E,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$0F,$10,$11
    !byte $FF,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$FF,$1B,$1C,$1D,$FF,$1E
    !byte $1F,$20,$FF,$FF,$21,$22,$23,$FF,$FF,$24,$FF,$FF,$FF,$25,$FF,$26
    !byte $FF,$FF,$27,$28,$FF,$29,$FF,$2A,$2B,$2C,$2D,$FF,$FF,$2E,$2F,$30
    !byte $31,$32,$FF,$33,$34,$35,$36,$FF,$37,$38,$39,$3A,$3B,$3C

; row hi=$D4 entries=70
gb_row_D4:
    !byte $C8,$08
    !byte $00,$01,$02,$03,$04,$FF,$FF,$FF,$FF,$05,$FF,$06,$07,$08,$FF,$09
    !byte $0A,$0B,$FF,$0C,$0D,$0E,$FF,$0F,$10,$11,$12,$13,$14,$15,$16,$17
    !byte $FF,$18,$19,$1A,$FF,$1B,$FF,$1C,$FF,$1D,$1E,$1F,$FF,$20,$21,$22
    !byte $FF,$23,$24,$25,$FF,$26,$27,$28,$29,$2A,$2B,$FF,$2C,$2D,$FF,$2E
    !byte $2F,$30,$31,$FF,$32,$33,$34,$FF,$FF,$35,$36,$37,$38,$39,$3A,$3B
    !byte $3C,$3D,$3E,$3F,$40,$41,$FF,$42,$43,$44,$FF,$45,$FF,$FF

; row hi=$D5 entries=53
gb_row_D5:
    !byte $0E,$09
    !byte $FF,$FF,$00,$FF,$FF,$FF,$FF,$01,$FF,$02,$FF,$03,$04,$05,$FF,$FF
    !byte $FF,$FF,$06,$07,$FF,$FF,$FF,$FF,$08,$FF,$FF,$09,$0A,$0B,$FF,$FF
    !byte $FF,$0C,$FF,$FF,$0D,$0E,$0F,$FF,$10,$11,$12,$13,$14,$FF,$15,$16
    !byte $FF,$17,$FF,$18,$19,$1A,$1B,$FF,$1C,$1D,$1E,$1F,$FF,$FF,$20,$FF
    !byte $FF,$21,$22,$23,$FF,$24,$FF,$FF,$FF,$FF,$25,$26,$27,$FF,$28,$29
    !byte $2A,$2B,$2C,$2D,$2E,$2F,$30,$FF,$31,$FF,$32,$FF,$33,$34

; row hi=$D6 entries=68
gb_row_D6:
    !byte $43,$09
    !byte $FF,$00,$01,$02,$03,$04,$05,$FF,$06,$07,$08,$09,$0A,$0B,$0C,$0D
    !byte $0E,$0F,$10,$11,$12,$FF,$13,$14,$15,$16,$17,$18,$19,$1A,$FF,$FF
    !byte $1B,$1C,$1D,$FF,$FF,$1E,$1F,$FF,$FF,$20,$FF,$FF,$FF,$21,$FF,$22
    !byte $FF,$23,$24,$FF,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$FF,$FF
    !byte $2F,$FF,$FF,$FF,$30,$31,$FF,$32,$33,$34,$35,$36,$37,$38,$FF,$39
    !byte $3A,$3B,$3C,$FF,$FF,$3D,$3E,$3F,$40,$41,$FF,$42,$FF,$43

; row hi=$D7 entries=58
gb_row_D7:
    !byte $87,$09
    !byte $00,$01,$02,$03,$04,$05,$FF,$06,$07,$08,$FF,$09,$FF,$0A,$0B,$0C
    !byte $FF,$0D,$0E,$0F,$FF,$FF,$10,$FF,$FF,$FF,$FF,$11,$12,$FF,$FF,$13
    !byte $FF,$FF,$FF,$FF,$14,$FF,$FF,$15,$FF,$16,$17,$18,$FF,$FF,$19,$1A
    !byte $1B,$FF,$1C,$1D,$FF,$1E,$FF,$1F,$20,$21,$22,$23,$24,$FF,$25,$26
    !byte $FF,$27,$28,$FF,$29,$2A,$FF,$2B,$2C,$2D,$FF,$2E,$2F,$30,$31,$32
    !byte $33,$34,$35,$FF,$FF,$36,$37,$38,$39,$FF,$FF,$FF,$FF,$FF
