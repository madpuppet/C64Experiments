#import "../includes/c64.lib"

:BasicUpstart2(start)

.label nextLine = $fc
.label color = $fd
.label spriteNumber = $ff

	* = 2064  "Main"
	
start:
    jsr initsprites

	lda #255                // enable all the sprites
	sta vic.spriteEnable
    sta vic.spriteMulticolor
	lda #0                  // reset sprites to size 0
    sta color
    sta spriteNumber
	sta vic.spriteYSize
    lda #255
	sta vic.spriteXSize     // double X size
    adc #128+64
    sta sprite0Ptr
    sta sprite1Ptr
    sta sprite2Ptr
    sta sprite3Ptr
    sta sprite4Ptr
    sta sprite5Ptr
    sta sprite6Ptr
    sta sprite7Ptr
    lda #128+64
	sta vic.spriteXMSB		// msb of x location for all 8 sprites - 7 & 8 on second half
    lda #2
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
    lda #3
    sta vic.borderColor


    clc
    lda #0
    ldx #0
initXLoop:
    sta vic.sprite0X,x
    inx
    inx
    adc #46
    cpx #16
    bne initXLoop

#if pork
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
#endif

	sei
	lda #$1b
	sta vic.control1  // clear significant bit in VICs raster register
	ldx #$00
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
    lda vic.rasterCounter
    beq done
newline:
    cmp vic.rasterCounter
    beq newline
done:
	lda nextLine
    sta vic.backgroundColor0
    pha
    clc
	adc #$19
    bcc ok
    ldy spriteNumber
    iny
    cpy #32
    bne nottoobig
    ldy #0
nottoobig:
    sty spriteNumber
    ldy color
    iny
    cpy #$16
    bne noreset
    ldy #0
noreset:
    sty color
    lda #0
ok:
	sta nextLine
    sta vic.rasterCounter

    adc #1
    sta vic.spriteMulticolor0
    adc #1
    sta vic.spriteMulticolor1

    // reposition sprite on Y axis
    pla
    pha
    clc
    adc #3
    sta vic.sprite0Y
    sta vic.sprite1Y
    sta vic.sprite2Y
    sta vic.sprite3Y
    sta vic.sprite4Y
    sta vic.sprite5Y
    sta vic.sprite6Y
    sta vic.sprite7Y

    // set sprite image to $3000 + 0..12
    lda spriteNumber
    adc nextLine
    lsr
    lsr
    and #7
    clc
    adc #128+64
    inc updateLoop2-1
updateLoop2:
    sta sprite0Ptr
    sta sprite1Ptr
    sta sprite2Ptr
    sta sprite3Ptr
    sta sprite4Ptr
    sta sprite5Ptr
    sta sprite6Ptr
    sta sprite7Ptr

    pla
    tax
    inx
    stx vic.sprite0Color
    inx
    stx vic.sprite1Color
    inx
    stx vic.sprite2Color
    inx
    stx vic.sprite3Color
    inx
    stx vic.sprite4Color
    inx
    stx vic.sprite5Color
    inx
    stx vic.sprite6Color
    inx
    stx vic.sprite7Color

    asl vic.interruptRegister
    jmp $ea81

initsprites:
    ldx #14
    ldy #7
    lda #60
initspriteloop1:
    sta vic.sprite0X,x
    adc #20
    pha
    lda #50
    sta vic.sprite0Y,x
    pla
    dex
    dex
    dey
    bpl initspriteloop1
    rts

    * = $3000 "Kangaroo Spirts"

.import binary "Kangaroo.raw"
