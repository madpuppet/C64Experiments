#import "../includes/c64.lib"

:BasicUpstart2(start)

.label nextLine = $fc
.label color = $fd
.label spriteNumber = $ff
.label firstRaster = 40

	* = 2064  "Main"
	
start:
	lda #255                // enable all the sprites
	sta vic.spriteEnable
	lda #0                  // reset sprites to size 0
    sta vic.spriteMulticolor
    sta color
    sta spriteNumber
    lda #255
	sta vic.spriteYSize
	sta vic.spriteXSize
    lda #128+64
    sta sprite0Ptr
    sta sprite1Ptr
    sta sprite2Ptr
    sta sprite3Ptr
    sta sprite4Ptr
    sta sprite5Ptr
    sta sprite6Ptr
    sta sprite7Ptr
    lda #0
	sta vic.spriteXMSB		// msb of x
    lda #7
    sta vic.sprite0Color
    sta vic.sprite1Color
    sta vic.sprite2Color
    sta vic.sprite3Color
    sta vic.sprite4Color
    sta vic.sprite5Color
    sta vic.sprite6Color
    sta vic.sprite7Color
    lda #6 
    sta vic.spriteMulticolor0
    lda #5
    sta vic.spriteMulticolor1

    lda #0
    sta vic.borderColor
    sta vic.backgroundColor0

    clc
    lda #24
    ldx #0
initXLoop:
    sta vic.sprite0X,x
    sta vic.sprite4X,x
    inx
    inx
    adc #48
    cpx #8
    bne initXLoop

    lda #50
    ldx #0
initYLoop:
    sta vic.sprite0Y,x
    inx
    inx
    cpx #16
    bne initYLoop

    // clear screen
    lda #32
    ldy #0
clearLoop:
    sta $0400,y
    sta $0400+240,y
    sta $0400+240*2,y
    sta $0400+240*3,y
    iny
    cpy #240
    bne clearLoop


	sei
	lda #$1b
	sta vic.control1  // clear significant bit in VICs raster register
	ldx #firstRaster
	stx nextLine
    stx vic.rasterCounter  // set raster line to interrupt on (#0)
	ldy #$7f
	sty $dc0d  // switch off interrupts from CIA-1
    Store(irq,$0314)
	lda #$01
    sta vic.interruptEnable  // enable raster interrupts
    cli
	
loop:
	jmp loop

irq:
{
    Store(irq2,$0314)

    lda nextLine
    pha
    clc
    adc #42
    bcc noOverflow
    lda #firstRaster
noOverflow:
    sta nextLine
    sta vic.rasterCounter
    asl vic.interruptRegister

    pla
    clc
    adc #10
    sta vic.sprite0Y
    sta vic.sprite1Y
    sta vic.sprite2Y
    sta vic.sprite3Y

    lda spriteNumber
    clc
    adc #128+64
    sta sprite0Ptr
    sta sprite1Ptr
    sta sprite2Ptr
    sta sprite3Ptr
    jmp $ea81
}

irq2:
{
    Store(irq,$0314)

    lda nextLine
    pha
    clc
    adc #42
    bcc noOverflow
    lda spriteNumber
    adc #0
    and #31
    sta spriteNumber
    lda #firstRaster
noOverflow:
    sta nextLine
    sta vic.rasterCounter
    asl vic.interruptRegister

    pla
    clc
    adc #10
    sta vic.sprite4Y
    sta vic.sprite5Y
    sta vic.sprite6Y
    sta vic.sprite7Y

    lda spriteNumber
    clc
    adc #128+64
    sta sprite4Ptr
    sta sprite5Ptr
    sta sprite6Ptr
    sta sprite7Ptr
    jmp $ea81
}

    * = $3000 "Sprite"

.import binary "Lightning.raw"
