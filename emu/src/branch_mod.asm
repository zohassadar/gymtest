
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


playstateJumpHi:
        .byte >exampleDestination
playstateJumpLo:
        .byte <exampleDestination

branchOnExample:
        ldx playState
        lda playstateJumpHi,x
        pha
        lda playstateJumpLo,x
        pha
        php
        rti
