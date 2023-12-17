marker = $EF

.include "common.asm"
        lda     #$FF
        ldx     #$02
        ldy     #$02
        jsr     memset_page
        lda #$FF
        sta marker

memset_page:
        pha
        txa
        sty     tmp2
        clc
        sbc     tmp2
        tax
        pla
        ldy     #$00
        sty     tmp1
@setByte:
        sta     (tmp1),y
        dey
        bne     @setByte
        dec     tmp2
        inx
        bne     @setByte
        rts
