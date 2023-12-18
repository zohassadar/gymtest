marker = $EF

.include "common.asm"
        jsr playState_checkForCompletedRows
        jsr playState_checkForCompletedRows
        jsr playState_checkForCompletedRows
        jsr playState_checkForCompletedRows
        lda #$FF
        sta marker

playState_checkForCompletedRows:
        lda vramRow
        cmp #$20
        bpl @updatePlayfieldComplete
        jmp playState_checkForCompletedRows_return

@updatePlayfieldComplete:

        lda tetriminoY
        sec
        sbc #$02
        bpl @yInRange
        lda #$00
@yInRange:
        clc
        adc lineIndex
        sta generalCounter2
        asl a
        sta generalCounter
        asl a
        asl a
        clc
        adc generalCounter
        sta generalCounter
        tay
        ldx #$0A

@checkIfRowComplete:
.if AUTO_WIN
        jmp @rowIsComplete
.endif
        lda practiseType
        cmp #MODE_TSPINS
        beq @rowNotComplete

        lda practiseType
        cmp #MODE_FLOOR
        beq @floorCheck
        lda linecapState
        cmp #LINECAP_FLOOR
        beq @fullRowBurningCheck
        bne @normalRow

@floorCheck:
        lda floorModifier
        beq @rowNotComplete

@fullRowBurningCheck:
        ; bugfix to ensure complete rows aren't cleared
        ; used in floor / linecap floor
        lda currentPiece_copy
        beq @IJLTedge
        cmp #5
        beq @IJLTedge
        cmp #$10
        beq @IJLTedge
        cmp #$12
        beq @IJLTedge
        bne @normalRow
@IJLTedge:
        lda lineIndex
        cmp #3
        bcs @rowNotComplete
@normalRow:


@checkIfRowCompleteLoopStart:
        lda (playfieldAddr),y
        cmp #EMPTY_TILE
        beq @rowNotComplete
        iny
        dex
        bne @checkIfRowCompleteLoopStart

@rowIsComplete:
        ; sound effect $A to slot 1 used to live here
        inc completedLines
        ldx lineIndex
        lda generalCounter2
        sta completedRow,x
        ldy generalCounter
        dey
@movePlayfieldDownOneRow:
        lda (playfieldAddr),y
        ldx #$0A
        stx playfieldAddr
        sta (playfieldAddr),y
        lda #$00
        sta playfieldAddr
        dey
        cpy #$FF
        bne @movePlayfieldDownOneRow
        lda #EMPTY_TILE
        ldy #$00
@clearRowTopRow:
        sta (playfieldAddr),y
        iny
        cpy #$0A
        bne @clearRowTopRow
        lda #$13
        sta currentPiece
        jmp @incrementLineIndex

@rowNotComplete:
        ldx lineIndex
        lda #$00
        sta completedRow,x
@incrementLineIndex:

        ; patch tapquantity data
        lda practiseType
        cmp #MODE_TAPQTY
        bne @tapQtyEnd
        lda completedLines
        cmp #0
        beq @tapQtyEnd
        ; mark as complete
        lda tqtyNext
        sta tqtyCurrent
        ; handle no burns
        lda tapqtyModifier
        and #$F0
        beq @tapQtyEnd
        lda #0
        sta vramRow
        inc playState
        inc playState
        lda #$07
        sta soundEffectSlot1Init
        rts
@tapQtyEnd:

        ; update top row for crunch
        lda practiseType
        cmp #MODE_CRUNCH
        bne @crunchEnd
        lda #1
        jsr advanceSides
@crunchEnd:

        lda completedLines
        beq :+
        lda #$0A
        sta soundEffectSlot1Init
:

        inc lineIndex
        lda lineIndex
        cmp #$04 ; check actual height
        bmi playState_checkForCompletedRows_return

        lda #$00
        sta vramRow
        sta rowY
        lda completedLines
        cmp #$04
        bne @skipTetrisSoundEffect
        lda #$04
        sta soundEffectSlot1Init
@skipTetrisSoundEffect:
        inc playState
        lda completedLines
        bne playState_checkForCompletedRows_return
@skipLines:
playState_completeRowContinue:
        inc playState
        lda #$07
        sta soundEffectSlot1Init
playState_checkForCompletedRows_return:
        rts



advanceGameCrunch:
    lda #0
    sta vramRow
    lda #20
advanceSides:
    pha
    sta tmp3
    lda crunchModifier
    lsr a
    lsr a
    ldx #0
    jsr advanceSide
    pla
    sta tmp3
    lda crunchModifier
    and #%00000011
    pha
    eor #$FF
    sec
    adc #0
    clc
    adc #10
    tax
    pla
    jsr advanceSide
    rts

advanceSide:
    cmp #0
    beq @end
    pha
    ldy #0
    txa
    clc
    adc #<playfield
    sta tmp1
    lda #>playfield
    sta tmp2
@rowLoop:
    pla
    pha
    tax
    beq @end
@blockLoop:
    lda #BLOCK_TILES
    sta (tmp1), y
    inc tmp1
    dex
    bne @blockLoop
    pla
    pha
    eor #$FF
    sec
    adc #0
    clc
    adc tmp1
    clc
    adc #10
    sta tmp1
    dec tmp3
    bne @rowLoop
    pla
@end:
    rts
