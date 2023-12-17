marker = $EF
result = $7FF

.include "common.asm"
        jsr playState_lockTetrimino
        lda #$FF
        sta marker


playState_lockTetrimino:

        ldy currentPiece
        sty currentPiece_copy ; this will conflict with floor mode mod
        lda orientationTiles,y
        sta generalCounter5
        tya
        asl a
        asl a
        tax
        lda #$04
        sta lineIndex ; conveniently leaves lineIndex 0 at return
; Copies a single square of the tetrimino to the playfield
@lockSquare:
        lda orientationYOffsets,x
        clc
        adc #$02
        clc
        adc tetriminoY
        tay

        lda orientationXOffsets,x
        clc
        adc tetriminoX
        clc
        adc multBy10OffsetBy2,y
        tay

        lda generalCounter5
        ; BLOCK_TILES
        sta playfield,y

        inx
        dec lineIndex
        bne @lockSquare
        ; jsr updatePlayfield
        ; jsr updateMusicSpeed
        ; inc playState
@ret:   rts


