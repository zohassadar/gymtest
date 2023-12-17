import itertools
import logging
import pathlib
import subprocess
import sys
import time

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

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
        tetriminoY=[0, 2, 17,18],
        tetriminoX=[1, 2, 6, 7],
        currentPiece=[0, 4, 10, 17, 18],
        playfieldAddrHi=[4],
    )
    playfields = ["empty"]
    results = list(i for i in range(0x400,0x500)) + [0x57]

testcases = [
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
    if not (original.compiled and modified.compiled):
        return total, failed
    for inputs in tests:
        for playfield in testcase.playfields:
            total+=1
            rambuffer[0x400:0x500] = playfields[playfield]
            named_inputs = list((key, value) for key, value in zip(names, inputs))
            for key, value in named_inputs:
                logger.debug(f"Setting {key} to {value}")
                rambuffer[RamMapper[key]] = sign(value)
            expected = original.run(rambuffer)
            tested = modified.run(rambuffer)
            for result in testcase.results:
                if expected[result] == tested[result]:
                    continue
                logger.error(
                    f"{result:04x} Expected: {expected[result]} Result: {tested[result]}  Inputs: {named_inputs!r}"
                )
                failed += 1
    return total, failed


def main():
    for testcase in testcases:
        start = time.perf_counter()
        total, failed = run_testcase(testcase)
        finish = time.perf_counter()
        print(f"{testcase.__name__}: {total-failed}/{total} succeeded in {finish-start:.2f} seconds")

class Emulator:
    def __init__(self, assembly: str):
        fullpath = pathlib.Path(assembly).absolute()
        logger.debug(f"{fullpath=}")
        name = fullpath.name.split(".")[0]
        path = fullpath.parent.parent
        objfile = path / "dbg" / f"{name}.o"
        listfile = path / "dbg" / f"{name}.lst"
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
            f"/usr/local/bin/ld65 -C /common/gymtest/emu/base.nes.cfg -o {self.binfile} {objfile}".split(),
            stderr=subprocess.PIPE,
        ).communicate()
        if err:
            print(err, file=sys.stderr)
            return
        self.compiled = True

    def run(self, rambuffer: bytearray):
        emu = subprocess.Popen(
            f"/common/gymtest/emu/ntools".split(),
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        result, error = emu.communicate(
            input=open(self.binfile, "rb").read() + rambuffer
        )
        if b"Cycles" in error:
            logger.debug(error.decode())
        elif error:
            logger.error(error)
        return result


if __name__ == "__main__":
    result = main()
