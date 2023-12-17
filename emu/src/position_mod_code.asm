; kept separately to reduce duplicating code.

isPositionValid:
       ; carry clear when valid
        lda currentPiece
        asl a
        asl a
        tax
isPositionValidPresetX:
        lda #$04
        sta generalCounter3
        clc ; carry only needs to be cleared entering loop
@checkSquare:
        ; validate y
        lda orientationYOffsets,x
        adc tetriminoY
        clc
        adc #$02
        cmp #$16
        bcs @ret ; y >= 20
        tay ; Used to get y * 10

        ; validate x
        lda orientationXOffsets,x
        adc tetriminoX
        cmp #$0A
        bcs @ret  ; x < 0 || x >= 10

        ; validate pos in playfield
        adc multBy10OffsetBy2,y
        tay
        lda #EMPTY_TILE-1
        cmp playfield,y
        bcs @ret ; Tile found in playfield

        inx
        dec generalCounter3
        bne @checkSquare
@ret:   rts


