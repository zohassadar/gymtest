marker = $EF
result = $7FF

.include "common.asm"
        jsr stageSpriteForCurrentPiece
        lda #$FF
        sta marker

stageSpriteForCurrentPiece:
        lda #$0
        sta pieceTileModifier
        jsr stageSpriteForCurrentPiece_actual

        lda practiseType
        cmp #MODE_HARDDROP
        beq ghostPiece
        rts

ghostPiece:
        lda playState
        cmp #3
        bpl @noGhost
        lda tetriminoY
        sta tmp3
@loop:
        inc tetriminoY
        jsr isPositionValid
        bcc @loop
        dec tetriminoY

        ; check if equal to current position
        lda tetriminoY
        cmp tmp3
        beq @noGhost

        lda frameCounter
        and #1
        asl
        asl
        adc #$0D
        sta pieceTileModifier
        jsr stageSpriteForCurrentPiece_actual
        lda tmp3
        sta tetriminoY
@noGhost:
        rts

xCoord = generalCounter3
yCoord = generalCounter4
tile = generalCounter5
tileCounter = generalCounter2
minimimYCoord = 47

stageSpriteForCurrentPiece_actual:
        lda tetriminoX
        cmp #TETRIMINO_X_HIDE
        beq @ret
        asl a
        asl a
        asl a
        adc #$60 ; clc omission is from original code.   3*asl for 0-9 will result in clear carry
        sta xCoord
        lda tetriminoY
        asl a
        asl a
        asl a
        clc
        adc #minimimYCoord
        sta yCoord
        lda currentPiece
        tay ; index into tiles
        asl
        asl
        tax ; index into Y & X Offsets
        lda orientationTiles,y
        ldy pieceTileModifier
        beq @storeTile
        bpl @tileMultiple
        tya
        bmi @storeTile
@tileMultiple:
        clc
        adc pieceTileModifier
@storeTile:
        ldy oamStagingLength
        sta oamStaging+1,y
        sta oamStaging+5,y
        sta oamStaging+9,y
        sta oamStaging+13,y
        lda #$04
        sta tileCounter
         ; y is oam y coordinate
@stageMino:  
        lda orientationYOffsets,x
        asl a
        asl a
        asl a
        clc
        adc yCoord
        cmp #minimimYCoord
        bcs @validY
        lda #$FF
@validY:
        sta oamStaging,y
        iny ; oam tile
        iny ; oam attribute
        lda #$02
        sta oamStaging,y
        iny ; oam x coordinate
        lda orientationXOffsets,x
        asl a
        asl a
        asl a
        clc
        adc xCoord
        sta oamStaging,y
@finishLoop:  
        iny
        inx
        dec tileCounter
        bne @stageMino
        sty oamStagingLength
@ret:   rts



isPositionValid:
       ; carry clear when valid
        lda currentPiece
        asl a
        asl a
        tax
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


