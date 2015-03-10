.include "constants.s"

.section .text

testStr:
.asciz	"TEST"
.align 	4

.globl	testGame

testGame:
moveTest$:		// move an object test
	
//	bne	moveTest$
	
firetest$:		// shoot a bullet test
	ldr r0,	=pawns_m	
	mov	r1,	#2
	bl	FireBullet
	ldr	r0,	=bullets_m
	ldrb	r4,	[r0, #BUL_X]
	ldrb	r5,	[r0, #BUL_Y]	
	cmp	r4,	#1
	bne	firetest$
	cmp	r5,	#0
	bne	firetest$
	ldrb	r4,	[r0, #BUL_DIR]
	cmp	r4,	#2
	ldrb	r4,	[r0, #BUL_FLG]
	cmp	r4,	#1
	bne	firetest$
	
	ldr	r0,	=bullets_m
	ldrb	r1,	[r0, #BUL_DIR]
	bl	MoveBullet

	ldr	r0,	=bullets_m
	ldrb	r4,	[r0, #BUL_X]
	ldrb	r5,	[r0, #BUL_Y]	
	cmp	r4,	#2
	bne	firetest$
	cmp	r5,	#0
	bne	firetest$

	ldr	r0,	=bullets_m
	mov	r1,	#4
	bl	MoveBullet

	ldr	r0,	=bullets_m
	ldrb	r4,	[r0, #BUL_X]
	ldrb	r5,	[r0, #BUL_Y]	
	ldrb	r6,	[r0, #BUL_DIR]	
	cmp	r4,	#2
	bne	firetest$
	cmp	r5,	#1
	bne	firetest$
	cmp	r6,	#4
	bne	firetest$

updatetest$:
	bl	UpdateEnemyBullets
	ldr	r0,	=bullets_m
	ldrb	r4,	[r0, #BUL_X]
	cmp	r4,	#2
	bne	updatetest$
	ldrb	r4,	[r0, #BUL_Y]	
	cmp	r4,	#2
	bne	updatetest$
	ldrb	r4,	[r0, #BUL_DIR]
	cmp	r4,	#4
	bne	updatetest$		
	ldrb	r4,	[r0, #BUL_FLG]
	cmp	r4,	#1
	bne	updatetest$	
	
	ldr	r0,	=pawns_m
	mov	r1,	#2
	strb	r1,	[r0, #OBJ_X]
	mov	r1,	#3
	strb	r1,	[r0, #OBJ_Y]

	bl	UpdateEnemyBullets

	ldr	r0,	=bullets_m
	ldr	r1,	=pawns_m
	bl	DetectHit
	cmp	r0,	#1
	ldr	r1,	=bullets_m
	ldr	r2,	=pawns_m
	bne	skip
	
	ldr	r0,	=bullets_m
	mov	r1,	#0
	strb	r1,	[r0, #BUL_FLG]

	ldr	r0,	=pawns_m
	ldrb	r1,	[r0, #OBJ_HP]
	sub	r1,	#10
	strb	r1,	[r0, #OBJ_HP]
skip:

	ldr	r0,	=pawns_m
	ldrb	r1,	[r0, #OBJ_HP]
	cmp	r1,	#-9
	ldr	r0,	=bullets_m
	ldrb	r4,	[r0, #BUL_X]
	cmp	r4,	#2
	bne	updatetest$
	ldrb	r4,	[r0, #BUL_Y]	
	cmp	r4,	#3
	bne	updatetest$
	ldrb	r4,	[r0, #BUL_DIR]
	cmp	r4,	#4
	bne	updatetest$		
	ldrb	r4,	[r0, #BUL_FLG]
	cmp	r4,	#0
	bne	updatetest$		

hittest$:		// bullet hit test

	ldr	r0,	=pawns_m
	mov	r1,	r0
	bl	DetectHit
	cmp	r0,	#1
	bne	hittest$
	bl	InitGame

	ldr	r0,	=pawns_m
	add	r1,	#OBJSIZE
	bl	DetectHit
	cmp	r0,	#1
	beq	hittest$
	ldr	r0,	=queens_m
	mov	r1,	#4
	bl	MoveObject
	ldr	r0,	=queens_m
	mov	r1,	#4
	bl	MoveObject
	ldr	r0,	=queens_m
	mov	r1,	#8
	bl	MoveObject
testGameLoop:
	ldr	r0,	=pawns_m
	ldr	r1,	=NumOfObjects
	bl	DrawScene
	bl	UpdateScene

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
	bl	UpdatePlayer
	bl	UpdateScene
	bl	DrawScene
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



