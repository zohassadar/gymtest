marker = $EF

.include "common.asm"
resetOAMStaging:
; Hide a sprite by moving it down offscreen, by writing any values between #$EF-#$FF here. 
; Sprites are never displayed on the first line of the picture, and it is impossible to place 
; a sprite partially off the top of the screen. 
; https://www.nesdev.org/wiki/PPU_OAM
        ldx #$00
        lda #$FF
@hideY:
        sta oamStaging,x
        inx
        inx
        inx
        inx
        bne @hideY

        lda #$FF
        sta marker
