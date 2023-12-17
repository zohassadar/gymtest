import itertools
import logging
import pathlib
import statistics
import subprocess
import sys
import time

import gymtest

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


class Branch:
    original = "emu/src/branch_orig.asm"
    modified = "emu/src/branch_mod.asm"
    inputs = dict(
        playState=[0],
    )
    playfields = ["empty"]
    results = [0xA8]



class StageTetrimino:
    original = "emu/src/stage_original.asm"
    modified = "emu/src/stage_modified.asm"
    inputs = dict(
        practiseType=[0, 0x13],
        tetriminoY=[0, 2, 17, 18],
        tetriminoX=[0, 1, 2, 6, 7],
        currentPiece=[0, 4, 10, 17, 18],
        playfieldAddrHi=[4],
    )
    playfields = ["empty", "full"]
    results = list(i for i in range(0x200, 0x300)) + [0xB3]


class StageTetriminoHidden:
    original = "emu/src/stage_original.asm"
    modified = "emu/src/stage_modified.asm"
    inputs = dict(
        practiseType=[0, 0x13],
        tetriminoY=[0],
        tetriminoX=[0],
        currentPiece=[19],
        playState=[3, 4, 5, 6, 7, 8],
        playfieldAddrHi=[4],
    )
    playfields = ["empty", "full"]
    results = list(i for i in range(0x200, 0x300)) + [0xB3]


class IsPositionValid:
    original = "emu/src/position_original.asm"
    modified = "emu/src/position_modified.asm"
    inputs = dict(
        tetriminoY=[0, 1, 2, 18, 19, 20],
        tetriminoX=[-1, 0, 1, 8, 9, 10],
        currentPiece=[0, 18],
        playfieldAddrHi=[4],
    )
    playfields = ["empty", "full"]
    results = [0x7FF]


class LockTetrimino:
    original = "emu/src/lock_original.asm"
    modified = "emu/src/lock_modified.asm"
    inputs = dict(
        tetriminoY=[0, 2, 17, 18],
        tetriminoX=[1, 2, 6, 7],
        currentPiece=[0, 4, 10, 17, 18],
        playfieldAddrHi=[4],
    )
    playfields = ["empty"]
    results = list(i for i in range(0x400, 0x500)) + [0x57]


class LockTetriminoGroup1:
    original = "emu/src/lock_original.asm"
    modified = "emu/src/lock_modified.asm"
    inputs = dict(
        tetriminoY=[0, 1, 18, 19],
        tetriminoX=[1, 2, 7, 8],
        currentPiece=[
            0x00,  # t up
            0x05,  # j up
            0x10,  # l up,
        ],
        playfieldAddrHi=[4],
    )
    playfields = ["empty"]
    results = list(i for i in range(0x400, 0x500)) + [0x57]


class LockTetriminoGroup2:
    original = "emu/src/lock_original.asm"
    modified = "emu/src/lock_modified.asm"
    inputs = dict(
        tetriminoY=[0, 1, 17, 18],
        tetriminoX=[1, 2, 8, 9],
        currentPiece=[
            0x02,  # t down
            0x07,  # j down
            0x08,  # z horiz
            0x0B,  # s horiz
            0x0E,  # l down
        ],
        playfieldAddrHi=[4],
    )
    playfields = ["empty"]
    results = list(i for i in range(0x400, 0x500)) + [0x57]


class LockTetriminoGroup3:
    original = "emu/src/lock_original.asm"
    modified = "emu/src/lock_modified.asm"
    inputs = dict(
        tetriminoY=[0, 1, 17, 18],
        tetriminoX=[0, 1, 7, 8],
        currentPiece=[
            0x00,  # t right
            0x06,  # j right
            0x09,  # z vert
            0x0C,  # s vert
            0x0D,  # l right
        ],
        playfieldAddrHi=[4],
    )
    playfields = ["empty"]
    results = list(i for i in range(0x400, 0x500)) + [0x57]


class LockTetriminoGroup4:
    original = "emu/src/lock_original.asm"
    modified = "emu/src/lock_modified.asm"
    inputs = dict(
        tetriminoY=[0, 1, 17, 18],
        tetriminoX=[1, 2, 8, 9],
        currentPiece=[
            0x03,  # t left
            0x06,  # j left
            0x0D,  # l left
        ],
        playfieldAddrHi=[4],
    )
    playfields = ["empty"]
    results = list(i for i in range(0x400, 0x500)) + [0x57]


class LockTetriminoIHoriz:
    original = "emu/src/lock_original.asm"
    modified = "emu/src/lock_modified.asm"
    inputs = dict(
        tetriminoY=[0, 1, 18, 19],
        tetriminoX=[2, 3, 7, 8],
        currentPiece=[
            0x10,  # i horiz
        ],
        playfieldAddrHi=[4],
    )
    playfields = ["empty"]
    results = list(i for i in range(0x400, 0x500)) + [0x57]


class LockTetriminoIVert:
    original = "emu/src/lock_original.asm"
    modified = "emu/src/lock_modified.asm"
    inputs = dict(
        tetriminoY=[0, 1, 17, 18],
        tetriminoX=[0, 1, 8, 9],
        currentPiece=[
            0x11,  # i Vert
        ],
        playfieldAddrHi=[4],
    )
    playfields = ["empty"]
    results = list(i for i in range(0x400, 0x500)) + [0x57]


class LockTetriminoO:
    original = "emu/src/lock_original.asm"
    modified = "emu/src/lock_modified.asm"
    inputs = dict(
        tetriminoY=[0, 1, 17, 18],
        tetriminoX=[1, 2, 8, 9],
        currentPiece=[
            0x0A,  # O
        ],
        playfieldAddrHi=[4],
    )
    playfields = ["empty"]
    results = list(i for i in range(0x400, 0x500)) + [0x57]


testcases = [
    Branch,
    LockTetrimino,
    LockTetriminoGroup1,
    LockTetriminoGroup2,
    LockTetriminoGroup3,
    LockTetriminoGroup4,
    LockTetriminoIHoriz,
    LockTetriminoIVert,
    LockTetriminoO,
    StageTetrimino,
    StageTetriminoHidden,
    IsPositionValid,
    LockTetrimino,
]


# grep zeropage *.dbg | awk -F, '{print $2,$8}' | grep val= | sed 's/name="//; s/" val=/ = /' | tac
RamMapper = dict(
    tmp1=0x0,
    tmp2=0x1,
    tmp3=0x2,
    tmpX=0x3,
    tmpY=0x4,
    tmpZ=0x5,
    tmpBulkCopyToPpuReturnAddr=0x6,
    binScore=0x8,
    score=0xC,
    activeMode=0x12,
    rng_seed=0x17,
    spawnID=0x19,
    spawnCount=0x1A,
    pointerAddr=0x1B,
    verticalBlankingInterval=0x33,
    set_seed=0x34,
    set_seed_input=0x37,
    tetriminoX=0x40,
    tetriminoY=0x41,
    currentPiece=0x42,
    levelNumber=0x44,
    fallTimer=0x45,
    autorepeatX=0x46,
    startLevel=0x47,
    playState=0x48,
    vramRow=0x49,
    completedRow=0x4A,
    autorepeatY=0x4E,
    holdDownPoints=0x4F,
    lines=0x50,
    rowY=0x52,
    linesBCDHigh=0x53,
    linesTileQueue=0x54,
    currentPiece_copy=0x55,
    completedLines=0x56,
    lineIndex=0x57,
    garbageHole=0x59,
    garbageDelay=0x5A,
    pieceTileModifier=0x5B,
    curtainRow=0x5C,
    mathRAM=0x60,
    byteSpriteAddr=0x72,
    byteSpriteTile=0x74,
    byteSpriteLen=0x75,
    spriteXOffset=0xA0,
    spriteYOffset=0xA1,
    spriteIndexInOamContentLookup=0xA2,
    outOfDateRenderFlags=0xA3,
    gameModeState=0xA7,
    generalCounter=0xA8,
    generalCounter2=0xA9,
    generalCounter3=0xAA,
    generalCounter4=0xAB,
    generalCounter5=0xAC,
    originalY=0xAE,
    dropSpeed=0xAF,
    tmpCurrentPiece=0xB0,
    frameCounter=0xB1,
    oamStagingLength=0xB3,
    newlyPressedButtons=0xB5,
    heldButtons=0xB6,
    playfieldAddr=0xB8,
    playfieldAddrHi=0xB9,
    allegro=0xBA,
    pendingGarbage=0xBB,
    renderMode=0xBD,
    nextPiece=0xBF,
    gameMode=0xC0,
    screenStage=0xC1,
    musicType=0xC2,
    sleepCounter=0xC3,
    endingSleepCounter=0xC4,
    endingRocketCounter=0xC6,
    endingRocketX=0xC7,
    endingRocketY=0xC8,
    demo_heldButtons=0xCE,
    demo_repeats=0xCF,
    demoButtonsAddr=0xD1,
    demoIndex=0xD3,
    highScoreEntryNameOffsetForLetter=0xD4,
    highScoreEntryRawPos=0xD5,
    highScoreEntryNameOffsetForRow=0xD6,
    highScoreEntryCurrentLetter=0xD7,
    lineClearStatsByType=0xD8,
    displayNextPiece=0xDF,
    AUDIOTMP1=0xE0,
    AUDIOTMP2=0xE1,
    AUDIOTMP3=0xE2,
    AUDIOTMP4=0xE3,
    AUDIOTMP5=0xE4,
    musicChanTmpAddr=0xE6,
    music_unused2=0xEA,
    soundRngSeed=0xEB,
    currentSoundEffectSlot=0xED,
    musicChannelOffset=0xEE,
    currentAudioSlot=0xEF,
    newlyPressedButtons_player1=0xF5,
    newlyPressedButtons_player2=0xF6,
    heldButtons_player1=0xF7,
    joy1Location=0xFB,
    ppuScrollY=0xFC,
    ppuScrollX=0xFD,
    currentPpuMask=0xFE,
    currentPpuCtrl=0xFF,
    stack=0x100,
    oamStaging=0x200,
    statsByType=0x3F0,
    playfield=0x400,
    practiseType=0x600,
    spawnDelay=0x601,
    dasValueDelay=0x602,
    dasValuePeriod=0x603,
    tspinX=0x604,
    tspinY=0x605,
    presetIndex=0x60E,
    tspinType=0x606,
    parityIndex=0x607,
    parityCount=0x608,
    parityColor=0x609,
    saveStateDirty=0x60A,
    saveStateSlot=0x60B,
    saveStateSpriteType=0x60C,
    saveStateSpriteDelay=0x60D,
    pausedOutOfDateRenderFlags=0x60F,
    debugLevelEdit=0x610,
    debugNextCounter=0x611,
    paceResult=0x612,
    paceSign=0x615,
    hzRAM=0x616,
    tqtyCurrent=0x621,
    tqtyNext=0x622,
    completedLinesCopy=0x623,
    lineOffset=0x624,
    harddropBuffer=0x625,
    linecapState=0x639,
    dasOnlyShiftDisabled=0x63A,
    invisibleFlag=0x63B,
    musicStagingSq1Lo=0x680,
    musicStagingSq1Hi=0x681,
    audioInitialized=0x682,
    musicPauseSoundEffectLengthCounter=0x683,
    musicStagingSq2Lo=0x684,
    musicStagingSq2Hi=0x685,
    resetSq12ForMusic=0x68A,
    musicPauseSoundEffectCounter=0x68B,
    musicStagingNoiseLo=0x68C,
    musicStagingNoiseHi=0x68D,
    musicDataNoteTableOffset=0x690,
    musicDataDurationTableOffset=0x691,
    musicDataChanPtr=0x692,
    musicChanControl=0x69A,
    musicChanVolume=0x69D,
    musicDataChanPtrDeref=0x6A0,
    musicDataChanPtrOff=0x6A8,
    musicDataChanInstructionOffset=0x6AC,
    musicDataChanInstructionOffsetBackup=0x6B0,
    musicChanNoteDurationRemaining=0x6B4,
    musicChanNoteDuration=0x6B8,
    musicChanProgLoopCounter=0x6BC,
    musicStagingSq1Sweep=0x6C0,
    musicChanNote=0x6C3,
    musicChanInhibit=0x6C8,
    musicTrack_dec=0x6CC,
    musicChanVolFrameCounter=0x6CD,
    musicChanLoFrameCounter=0x6D1,
    soundEffectSlot0FrameCount=0x6D5,
    soundEffectSlot0FrameCounter=0x6DA,
    soundEffectSlot0SecondaryCounter=0x6DF,
    soundEffectSlot1SecondaryCounter=0x6E0,
    soundEffectSlot3SecondaryCounter=0x6E2,
    soundEffectSlot0TertiaryCounter=0x6E3,
    soundEffectSlot1TertiaryCounter=0x6E4,
    soundEffectSlot3TertiaryCounter=0x6E6,
    soundEffectSlot0Tmp=0x6E7,
    soundEffectSlot1Tmp=0x6E8,
    soundEffectSlot0Init=0x6F0,
    soundEffectSlot1Init=0x6F1,
    musicTrack=0x6F5,
    soundEffectSlot0Playing=0x6F8,
    soundEffectSlot1Playing=0x6F9,
    soundEffectSlot3Playing=0x6FB,
    soundEffectSlot4Playing=0x6FC,
    currentlyPlayingMusicTrack=0x6FD,
    initMagic=0x75B,
    menuSeedCursorIndex=0x760,
    menuScrollY=0x761,
    menuMoveThrottle=0x762,
    menuThrottleTmp=0x763,
    levelControlMode=0x764,
    customLevel=0x765,
    classicLevel=0x766,
    heartsAndReady=0x767,
    linecapCursorIndex=0x768,
    linecapWhen=0x769,
    linecapHow=0x76A,
    linecapLevel=0x76B,
    linecapLines=0x76C,
    paceModifier=0x76E,
    presetModifier=0x76F,
    typeBModifier=0x770,
    floorModifier=0x771,
    crunchModifier=0x772,
    tapModifier=0x773,
    transitionModifier=0x774,
    tapqtyModifier=0x775,
    checkerModifier=0x776,
    garbageModifier=0x777,
    droughtModifier=0x778,
    dasModifier=0x779,
    scoringModifier=0x77A,
    hzFlag=0x77B,
    inputDisplayFlag=0x77C,
    disableFlashFlag=0x77D,
    disablePauseFlag=0x77E,
    goofyFlag=0x77F,
    debugFlag=0x780,
    linecapFlag=0x781,
    dasOnlyFlag=0x782,
    qualFlag=0x783,
    palFlag=0x784,
)

playfields = dict(
    empty=bytes(0xEF for i in range(256)),
    full=bytes(0x7C for i in range(256)),
)


def sign(value):
    return 256 + value if value < 0 else value


def run_testcase(testcase):
    total = 0
    failed = 0
    rambuffer = bytearray(2048)
    names = testcase.inputs.keys()
    tests = itertools.product(*testcase.inputs.values())
    original = Emulator(testcase.original)
    modified = Emulator(testcase.modified)
    original_cycles = []
    modified_cycles = []
    if not (original.compiled and modified.compiled):
        return total, failed
    for inputs in tests:
        for playfield in testcase.playfields:
            total += 1
            rambuffer[0x400:0x500] = playfields[playfield]
            named_inputs = list((key, value) for key, value in zip(names, inputs))
            for key, value in named_inputs:
                logger.debug(f"Setting {key} to {value}")
                rambuffer[RamMapper[key]] = sign(value)
            expected, orig_cycles = original.run(rambuffer)
            original_cycles.append(orig_cycles)
            tested, mod_cycles = modified.run(rambuffer)
            modified_cycles.append(mod_cycles)
            for result in testcase.results:
                if expected[result] == tested[result]:
                    continue

                # account for the different methods of hiding sprites.  The tile will be 0xFF for original, y pos is 0xff in modified.
                if (
                    result & 0xF00 == 0x200
                    and expected[result // 4 * 4 + 1] == tested[result // 4 * 4]
                ):
                    continue
                if (
                    result & 0xF00 == 0x200
                    and expected[result // 4 * 4 + 1] & 0b11101111
                    == tested[result // 4 * 4 + 1] & 0b11101111
                ):
                    continue
                logger.error(
                    f"{result:04x} Expected: {expected[result]} Result: {tested[result]}  Inputs: {named_inputs!r}"
                )
                failed += 1
                break
    return (
        total,
        failed,
        min(original_cycles),
        min(modified_cycles),
        max(original_cycles),
        max(modified_cycles),
        statistics.mean(original_cycles),
        statistics.mean(modified_cycles),
        statistics.median(original_cycles),
        statistics.median(modified_cycles),
    )


def main():
    arg = sys.argv[1] if sys.argv[1:] else None
    for testcase in testcases:
        if arg and arg not in testcase.__name__:
            continue
        start = time.perf_counter()
        (
            total,
            failed,
            orig_min,
            mod_min,
            orig_max,
            mod_max,
            orig_mean,
            mod_mean,
            orig_med,
            mod_med,
        ) = run_testcase(testcase)
        finish = time.perf_counter()
        print(
            f"{testcase.__name__}: {total-failed}/{total} succeeded in {finish-start:.2f} seconds"
        )
        print(
            f"Min: {orig_min}/{mod_min} Max: {orig_max}/{mod_max} Mean: {orig_mean:.0f}/{mod_mean:.0f} Median: {orig_med:.0f}/{mod_med:.0f}\n"
        )


class Emulator:
    def __init__(self, assembly: str):
        fullpath = pathlib.Path(assembly).absolute()
        logger.debug(f"{fullpath=}")
        name = fullpath.name.split(".")[0]
        path = fullpath.parent.parent
        objfile = path / "dbg" / f"{name}.o"
        listfile = path / "dbg" / f"{name}.lst"
        dbgfile = path / "dbg" / f"{name}.dbg"
        self.binfile = path / "bin" / f"{name}.nes"
        self.compiled = False
        _, err = subprocess.Popen(
            f"/usr/local/bin/ca65 -l {listfile} -g {fullpath} -o {objfile}".split(),
            stderr=subprocess.PIPE,
        ).communicate()
        if err:
            print(err, file=sys.stderr)
            return
        _, err = subprocess.Popen(
            f"/usr/local/bin/ld65 -C /common/gymtest/emu/base.nes.cfg --dbgfile {dbgfile} -o {self.binfile} {objfile}".split(),
            stderr=subprocess.PIPE,
        ).communicate()
        if err:
            print(err, file=sys.stderr)
            return
        self.compiled = True
        self.rom = open(self.binfile, 'rb').read()

    def run(self, rambuffer: bytearray):
        return gymtest.run(self.rom, rambuffer)


if __name__ == "__main__":
    result = main()
