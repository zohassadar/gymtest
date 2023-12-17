marker = $EF
result = $7FF

.include "common.asm"
        jsr isPositionValid
        ; original uses zero flag to communicate validity, but also leaves $0 or $FF in accumulator 
        ; This converts to a common result format and location.
        and #$80
        sta result
        lda #$FF
        sta marker

.include "position_orig_code.asm"




