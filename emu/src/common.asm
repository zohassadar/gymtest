        .setcpu "6502"
.ifndef INES_MAPPER ; is set via ca65 flags
INES_MAPPER := 1 ; supports 1, 3 and 4 (MMC1 / CNROM / MMC3)
.endif

HAS_MMC = INES_MAPPER = 1 || INES_MAPPER = 4 || INES_MAPPER = 5

.ifndef SAVE_HIGHSCORES
SAVE_HIGHSCORES := 1
.endif

.ifndef AUTO_WIN
; faster aeppoz + press select to end game
AUTO_WIN := 0
.endif

.ifndef KEYBOARD
KEYBOARD := 0
.endif

NO_MUSIC := 1

; dev flags
NO_SCORING := 0 ; breaks pace
NO_SFX := 0
NO_MENU := 0
ALWAYS_CURTAIN := 0
QUAL_BOOT := 0

INITIAL_CUSTOM_LEVEL := 29
INITIAL_LINECAP_LEVEL := 39
INITIAL_LINECAP_LINES := $30 ; bcd
INITIAL_LINECAP_LINES_1 := 3 ; hex (lol)
BTYPE_START_LINES := $25 ; bcd
MENU_HIGHLIGHT_COLOR := $12 ; $12 in gym, $16 in original
BLOCK_TILES := $7B
EMPTY_TILE := $EF
TETRIMINO_X_HIDE := $EF

PAUSE_SPRITE_X := $74
PAUSE_SPRITE_Y := $58
; yobi-style
; PAUSE_SPRITE_X := $C4
; PAUSE_SPRITE_Y := $16

BUTTON_DOWN := $4
BUTTON_UP := $8
BUTTON_RIGHT := $1
BUTTON_LEFT := $2
BUTTON_B := $40
BUTTON_A := $80
BUTTON_SELECT := $20
BUTTON_START := $10
BUTTON_DPAD := BUTTON_UP | BUTTON_DOWN | BUTTON_LEFT | BUTTON_RIGHT

.enum
MODE_TETRIS
MODE_TSPINS
MODE_SEED
MODE_PARITY
MODE_PACE
MODE_PRESETS
MODE_TYPEB
MODE_FLOOR
MODE_CRUNCH
MODE_TAP
MODE_TRANSITION
MODE_MARATHON
MODE_TAPQTY
MODE_CHECKERBOARD
MODE_GARBAGE
MODE_DROUGHT
MODE_DAS
MODE_KILLX2
MODE_INVISIBLE
MODE_HARDDROP
MODE_SPEED_TEST
MODE_SCORE_DISPLAY
MODE_HZ_DISPLAY
MODE_INPUT_DISPLAY
MODE_DISABLE_FLASH
MODE_DISABLE_PAUSE
MODE_GOOFY
MODE_DEBUG
MODE_LINECAP
MODE_DASONLY
MODE_QUAL
MODE_PAL
.endenum

MODE_QUANTITY = MODE_PAL + 1
MODE_GAME_QUANTITY = MODE_HARDDROP + 1

SCORING_CLASSIC := 0 ; for scoringModifier
SCORING_LETTERS := 1
SCORING_SEVENDIGIT := 2
SCORING_FLOAT := 3
SCORING_SCORECAP := 4
SCORING_HIDDEN := 5

LINECAP_KILLX2 := 1
LINECAP_FLOOR := 2
LINECAP_INVISIBLE := 3
LINECAP_HALT := 4

LINECAP_WHEN_STRING_OFFSET := $10
LINECAP_HOW_STRING_OFFSET := $12

MENU_SPRITE_Y_BASE := $47
MENU_MAX_Y_SCROLL := $78
MENU_TOP_MARGIN_SCROLL := 7 ; in blocks

; menuConfigSizeLookup
; menu ram is defined at menuRAM in ./ram.asm
.macro MENUSIZES 
    .byte $0    ; MODE_TETRIS
    .byte $0    ; MODE_TSPINS
    .byte $0    ; MODE_SEED
    .byte $0    ; MODE_PARITY
    .byte $F    ; MODE_PACE
    .byte $7    ; MODE_PRESETS
    .byte $8    ; MODE_TYPEB
    .byte $C    ; MODE_FLOOR
    .byte $F    ; MODE_CRUNCH
    .byte $20   ; MODE_TAP
    .byte $10   ; MODE_TRANSITION
    .byte $0    ; MODE_MARATHON
    .byte $1F   ; MODE_TAPQTY
    .byte $8    ; MODE_CHECKERBOARD
    .byte $4    ; MODE_GARBAGE
    .byte $12   ; MODE_DROUGHT
    .byte $10   ; MODE_DAS
    .byte $0    ; MODE_KILLX2
    .byte $0    ; MODE_INVISIBLE
    .byte $0    ; MODE_HARDDROP
    .byte $0    ; MODE_SPEED_TEST
    .byte $5    ; MODE_SCORE_DISPLAY
    .byte $1    ; MODE_HZ_DISPLAY
    .byte $1    ; MODE_INPUT_DISPLAY
    .byte $1    ; MODE_DISABLE_FLASH
    .byte $1    ; MODE_DISABLE_PAUSE
    .byte $1    ; MODE_GOOFY
    .byte $1    ; MODE_DEBUG
    .byte $1    ; MODE_LINECAP
    .byte $1    ; MODE_DASONLY
    .byte $1    ; MODE_QUAL
    .byte $1    ; MODE_PAL
.endmacro

.macro MODENAMES
    .byte   "TETRIS"
    .byte   "TSPINS"
    .byte   " SEED "
    .byte   "STACKN"
    .byte   " PACE "
    .byte   "SETUPS"
    .byte   "B-TYPE"
    .byte   "FLOOR "
    .byte   "CRUNCH"
    .byte   "QCKTAP"
    .byte   "TRNSTN"
    .byte   "MARTHN"
    .byte   "TAPQTY"
    .byte   "CKRBRD"
    .byte   "GARBGE"
    .byte   "LOBARS"
    .byte   "DASDLY"
    .byte   "KILLX2"
    .byte   "INVZBL"
    .byte   "HRDDRP"
.endmacro





.include "ram.asm"

.segment    "PRG_chunk2": absolute
.align $100
musicSelectionTable:
        .byte   $03,$04,$05,$FF,$06,$07,$08,$FF

multBy10OffsetBy2:
        .byte   $EC,$F6
multBy10Table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE

.align $100
orientationTable:
        .byte   $00,$7B,$FF,$00,$7B,$00,$00,$7B
        .byte   $01,$FF,$7B,$00,$FF,$7B,$00,$00
        .byte   $7B,$00,$00,$7B,$01,$01,$7B,$00
        .byte   $00,$7B,$FF,$00,$7B,$00,$00,$7B
        .byte   $01,$01,$7B,$00,$FF,$7B,$00,$00
        .byte   $7B,$FF,$00,$7B,$00,$01,$7B,$00
        .byte   $FF,$7D,$00,$00,$7D,$00,$01,$7D
        .byte   $FF,$01,$7D,$00,$FF,$7D,$FF,$00
        .byte   $7D,$FF,$00,$7D,$00,$00,$7D,$01
        .byte   $FF,$7D,$00,$FF,$7D,$01,$00,$7D
        .byte   $00,$01,$7D,$00,$00,$7D,$FF,$00
        .byte   $7D,$00,$00,$7D,$01,$01,$7D,$01
        .byte   $00,$7C,$FF,$00,$7C,$00,$01,$7C
        .byte   $00,$01,$7C,$01,$FF,$7C,$01,$00
        .byte   $7C,$00,$00,$7C,$01,$01,$7C,$00
        .byte   $00,$7B,$FF,$00,$7B,$00,$01,$7B
        .byte   $FF,$01,$7B,$00,$00,$7D,$00,$00
        .byte   $7D,$01,$01,$7D,$FF,$01,$7D,$00
        .byte   $FF,$7D,$00,$00,$7D,$00,$00,$7D
        .byte   $01,$01,$7D,$01,$FF,$7C,$00,$00
        .byte   $7C,$00,$01,$7C,$00,$01,$7C,$01
        .byte   $00,$7C,$FF,$00,$7C,$00,$00,$7C
        .byte   $01,$01,$7C,$FF,$FF,$7C,$FF,$FF
        .byte   $7C,$00,$00,$7C,$00,$01,$7C,$00
        .byte   $FF,$7C,$01,$00,$7C,$FF,$00,$7C
        .byte   $00,$00,$7C,$01,$FE,$7B,$00,$FF
        .byte   $7B,$00,$00,$7B,$00,$01,$7B,$00
        .byte   $00,$7B,$FE,$00,$7B,$FF,$00,$7B
        .byte   $00,$00,$7B,$01,$00,$FF,$00,$00
        .byte   $FF,$00,$00,$FF,$00,$00,$FF,$00
.align $100
orientationYOffsets:
        .byte   $00,$00,$00,$FF ; t
        .byte   $FF,$00,$00,$01
        .byte   $00,$00,$00,$01
        .byte   $FF,$00,$00,$01 

        .byte   $FF,$00,$01,$01 ; j
        .byte   $FF,$00,$00,$00
        .byte   $FF,$FF,$00,$01
        .byte   $00,$00,$00,$01

        .byte   $00,$00,$01,$01 ; z
        .byte   $FF,$00,$00,$01

        .byte   $00,$00,$01,$01 ; o

        .byte   $00,$00,$01,$01 ; s
        .byte   $FF,$00,$00,$01

        .byte   $FF,$00,$01,$01 ; l
        .byte   $00,$00,$00,$01
        .byte   $FF,$FF,$00,$01
        .byte   $FF,$00,$00,$00

        .byte   $FE,$FF,$00,$01 ; i
        .byte   $00,$00,$00,$00

        .byte   $00,$00,$00,$00 ; hidden
.align $100
orientationXOffsets:
        .byte   $FF,$00,$01,$00 ; t
        .byte   $00,$00,$01,$00
        .byte   $FF,$00,$01,$00
        .byte   $00,$FF,$00,$00

        .byte   $00,$00,$FF,$00 ; j
        .byte   $FF,$FF,$00,$01
        .byte   $00,$01,$00,$00
        .byte   $FF,$00,$01,$01

        .byte   $FF,$00,$00,$01 ; z
        .byte   $01,$00,$01,$00

        .byte   $FF,$00,$FF,$00 ; o

        .byte   $00,$01,$FF,$00 ; s
        .byte   $00,$00,$01,$01

        .byte   $00,$00,$00,$01 ; l
        .byte   $FF,$00,$01,$FF
        .byte   $FF,$00,$00,$00
        .byte   $01,$FF,$00,$01

        .byte   $00,$00,$00,$00 ; i
        .byte   $FE,$FF,$00,$01

        .byte   $00,$00,$00,$00 ; hidden
.align $100
orientationTiles:
        .byte $7B,$7B,$7B,$7B   ; t
        .byte $7D,$7D,$7D,$7D   ; j
        .byte $7C,$7C           ; z
        .byte $7B               ; o
        .byte $7D,$7D           ; s
        .byte $7C,$7C,$7C,$7C   ; l
        .byte $7B,$7B           ; i
        .byte EMPTY_TILE

.segment    "PRG_chunk1": absolute