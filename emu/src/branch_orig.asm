
marker = $EF
result = $7FF

.include "common.asm"
        jsr branchOnExample
        lda #$FF
        sta marker

exampleDestination:
        lda #$42
        sta generalCounter
        rts

branchOnExample:
        lda playState
        jsr switch_s_plus_2a
        .addr   exampleDestination ; gms: 1 acc: 0 - ne

switch_s_plus_2a:
        asl a
        tay
        iny
        pla
        sta tmp1
        pla
        sta tmp2
        lda (tmp1),y
        tax
        iny
        lda (tmp1),y
        sta tmp2
        stx tmp1
        jmp (tmp1)
