.section .text

testStr:
.asciz	"TEST"
.align 	4

.globl	testMain
testMain:
	bl	InitSNES
	mov	r4,	#100	
	mov	r5,	#200

gameLoop$:
	ldr	r6,	=0xFFFF
	bl	ReadSNES
	ldr	r1,	=SNESpad	
	ldr	r1,	[r1]	
	cmp	r1,	r6	// if no buttons pressed
	beq	gameLoop$

drawLoop$:	
	bl	ClearScreen
	//bl	ErasePlayer
	bl	UpdatePlayer
	bl	DrawPlayer

myTest:
	mov	r1,	#0
	mov	r2,	#0
	ldr	r3,	=0xFF0F
	ldr	r4,	=1023
	ldr	r5,	=767
	push	{r1-r5}
	bl	DrawEmptyRectangle
	pop	{r1-r5}

	mov	r1,	#100
	mov	r2,	#100
	ldr	r3,	=0xFF0F
	ldr	r4,	=500
	ldr	r5,	=17
	push	{r1-r5}
	bl	DrawEmptyRectangle
	pop	{r1-r5}

	ldr	r0,	=testStr
	mov	r1,	#300
	mov	r2,	#300
	ldr	r3,	=0xFFFF
	bl	DrawString

	mov	r0,	#50
	mov	r1,	#100
	mov	r2,	#50
	ldr	r3,	=0xF00F
	bl	DrawHorizontalLine

	ldr	r0,	=50
	mov	r1,	#200
	mov	r2,	#200
	ldr	r3,	=0xF00F
	bl	DrawVerticalLine

	ldr	r0,	=FrameBufferPointer
	ldr	r0,	[r0]
	mov	r1,	#500
	mov	r2,	#100
	ldr	r3,	=0xF00F
	bl	DrawPixel16bpp

	ldr	r6,	=0xFFFF
inputLoop1$:	
	bl	ReadSNES	
	ldr	r1,	=SNESpad
	ldr	r1,	[r1]	
	cmp	r1,	r6	// if no buttons pressed
	bne	inputLoop1$
	ldr	r0,	=0xFFFF
	bl	Wait
	b	gameLoop$
haltLoop$:
	b		haltLoop$



