#import "../includes/c64.lib"

:BasicUpstart2(start)

.label inptr = $fb
.label outptr = $fd

	* = 2064  "Main"
	
start:
	sei

    // point custom character set to our char set data        
    lda $d018
    and #$f0
    clc
    ora #$0c
    sta $d018
    
    lda #0
    sta $d020
    sta $d021

    // play music
	lda #$1b
	sta $d011  // clear significant bit in VICs raster register
	ldx #$00
	stx $d012  // set raster line to interrupt on (#0)
	ldy #$7f
	sty $dc0d  // switch off interrupts from CIA-1
	lda #<irq
	ldx #>irq
	sta $0314  // set IRQ callback vector
	stx $0315

	lda #$01
	sta $d01a  // enable raster interrupts

	lda #$00
	jsr $1000
	cli
	
restart:
    // clear the screen data to the screen     
    lda #0
    ldy #0
clrloop:
    sta $0400,y
    sta $04FA,y
    sta $05F4,y
    sta $06EE,y
    iny
    cpy #250
    bne clrloop
            
    // now process each frame
    // decompress from inptr -> outptr
    lda #$00
    sta outptr
    sta inptr
    lda #$04
    sta outptr+1
    lda #$38
    sta inptr+1

startPage:    
    sei
    jsr pageInAnim
process:
    ldy #0
    lda (inptr),y
    tax
    lda #1
    clc
    adc inptr
    sta inptr
    lda #0
    adc inptr+1
    sta inptr+1
    txa
    and #3
    asl
    tay
    lda rleTable,y
    sta jumper+1
    lda rleTable+1,y
    sta jumper+2
    lda #>(process-1)
    pha
    lda #<(process-1)
    pha
    txa
    lsr
    lsr
    clc
    adc #1
    
jumper:
    jmp $8000
    
rleEnd:
    pla
    pla
    jsr pageOutAnim
    cli
    
    lda #$00
    sta outptr
    lda #$04
    sta outptr+1

    lda inptr+1
    cmp #>endOfData
    bne notDone
    lda inptr
    cmp #<endOfData
    bne notDone
    jsr delay
    jmp restart
notDone: 
    jsr delay
    jmp startPage

delay: 
    jsr waitFrame
    rts

waitFrame:
    lda #$80
    cmp $d012 
    bne waitFrame
waitFrame2:
    lda #$81
    cmp $d012 
    bne waitFrame2
waitFrameDone:
    rts
    
rleSkip:
    clc
    adc outptr
    sta outptr
    lda #0
    adc outptr+1
    sta outptr+1
    rts

rleLiteral:
    pha
    ldy #0
    tax
loopLiteral:
    lda (inptr),y
    sta (outptr),y
    iny
    dex
    bne loopLiteral
    pla
    tax
    clc
    adc inptr
    sta inptr
    lda #0
    adc inptr+1
    sta inptr+1
    txa
    clc
    adc outptr
    sta outptr
    lda #0
    adc outptr+1
    sta outptr+1
    rts

rleRepeat:
    pha
    tax
    ldy #0
    lda (inptr),y
    
loopRepeat:
    sta (outptr),y
    iny
    dex
    bne loopRepeat
    lda #1
    clc
    adc inptr
    sta inptr
    lda #0
    adc inptr+1
    sta inptr+1
    pla
    clc
    adc outptr
    sta outptr
    lda #0
    adc outptr+1    
    sta outptr+1
    rts    
    
pageInAnim:
    pha
    lda $1
    and #$f8
    sta $1
    pla
    rts
    
pageOutAnim:
    pha
    lda $1
    ora #7
    sta $1
    pla
    rts
    
irq:
    asl $d019
    jsr $1006
    jmp $ea81
    
rleTable:
    .word rleEnd, rleSkip, rleLiteral, rleRepeat

   * = $1000-$7E "SID Data"

.import binary "music.sid"

   * = $3000 "Char Data"
	
.import binary "charset.dat"

    * = $3800 "Dancing Data"
    
//.import binary "juggling.dat"
//.import binary "boingball.dat"
//.import binary "hitormiss.dat"
.import binary "c64ad.dat"

endOfData:

