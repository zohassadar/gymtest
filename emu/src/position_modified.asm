marker = $EF
result = $7FF

.include "common.asm"
        jsr isPositionValid
        ; modified uses carry bit to communicate validity vs original which uses zero flag
        ; This converts to a common result format and location.
        lda #$00
        ror
        sta result
        lda #$FF
        sta marker

.include "position_mod_code.asm"


