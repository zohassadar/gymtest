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
        beq @loop
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



tileModifierForCurrentPiece:
        lda pieceTileModifier
        beq @tileNormal
        and #$80
        bne @tileSingle
; @tileMultiple:
        lda orientationTable,x
        clc
        adc pieceTileModifier
        rts
@tileSingle:
        lda pieceTileModifier
        rts
@tileNormal:
        lda orientationTable,x
        rts

stageSpriteForCurrentPiece_actual:
        lda tetriminoX
        cmp #TETRIMINO_X_HIDE
        beq stageSpriteForCurrentPiece_return
        asl a
        asl a
        asl a
        adc #$60
        sta generalCounter3
        clc
        lda tetriminoY
        rol a
        rol a
        rol a
        adc #$2F
        sta generalCounter4
        lda currentPiece
        sta generalCounter5
        clc
        lda generalCounter5
        rol a
        rol a
        sta generalCounter
        rol a
        adc generalCounter
        tax
        ldy oamStagingLength
        lda #$04
        sta generalCounter2
@stageMino:  
        lda orientationTable,x
        asl a
        asl a
        asl a
        clc
        adc generalCounter4
        sta oamStaging,y
        sta originalY
        inc oamStagingLength
        iny
        inx
        jsr tileModifierForCurrentPiece ; used to just load from orientationTable
        ; lda orientationTable, x
        sta oamStaging,y
        inc oamStagingLength
        iny
        inx
        lda #$02
        sta oamStaging,y
        lda originalY
        cmp #$2F
        bcs @validYCoordinate
        inc oamStagingLength
        dey
        lda #$FF
        sta oamStaging,y
        iny
        iny
        lda #$00
        sta oamStaging,y
        jmp @finishLoop

@validYCoordinate:  
        inc oamStagingLength
        iny
        lda orientationTable,x
        asl a
        asl a
        asl a
        clc
        adc generalCounter3
        sta oamStaging,y
@finishLoop:  
        inc oamStagingLength
        iny
        inx
        dec generalCounter2
        bne @stageMino
stageSpriteForCurrentPiece_return:
        rts



isPositionValid:
        lda tetriminoY
        asl a
        sta generalCounter
        asl a
        asl a
        clc
        adc generalCounter
        adc tetriminoX
        sta generalCounter
        lda currentPiece
        asl a
        asl a
        sta generalCounter2
        asl a
        clc
        adc generalCounter2
        tax
        ldy #$00
        lda #$04
        sta generalCounter3
; Checks one square within the tetrimino
@checkSquare:
        lda orientationTable,x
        clc
        adc tetriminoY
        adc #$02

        cmp #$16
        bcs @invalid
        lda orientationTable,x
        asl a
        sta generalCounter4
        asl a
        asl a
        clc
        adc generalCounter4
        clc
        adc generalCounter
        sta positionValidTmp
        inx
        inx
        lda orientationTable,x
        clc
        adc positionValidTmp
        tay
        lda (playfieldAddr),y
        cmp #EMPTY_TILE
        bcc @invalid
        lda orientationTable,x
        clc
        adc tetriminoX
        cmp #$0A
        bcs @invalid
        inx
        dec generalCounter3
        bne @checkSquare
        lda #$00
        sta generalCounter
        rts

@invalid:
        lda #$FF
        sta generalCounter
        rts
