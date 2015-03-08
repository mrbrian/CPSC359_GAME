.section .text

.equ	OBJSIZE,	8
.equ	MAX_PX,		31
.equ	MAX_PY,		23

OBJ_X = 0
OBJ_Y = 1
OBJ_W = 2
OBJ_H = 3
OBJ_VAL = 4
OBJ_HP = 5
OBJ_CLR = 6
		
.globl	testGame

moveTest$:		// move an object test
	bne	moveTest$
	
firetest$:		// shoot a bullet test
	ldr r0,	=pawns_m	
	ldr r2,	[r0]
	add	r2,	#1
	ldr r3,	[r0, #1]	
	mov	r1,	#2
	bl	FireBullet
	ldr	r0,	=bullets_m
	ldr	r4,	[r0]
	ldr	r5,	[r0, #1]	
	cmp	r2,	r4
	bne	firetest$
	cmp	r3,	r5
	bne	firetest$
	ldr	r4,	[r0, #5]
	cmp	r4,	#1
	bne	firetest$
		
hittest$:		// bullet hit test

testGame:
	ldr	r0,	=pawns_m
	mov	r1,	r0
	bl	DetectHit
	bl	InitGame

	ldr	r0,	=pawns_m
	add	r1,	#OBJSIZE
	bl	DetectHit

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
	b	testGameLoop

/* Position the game objects */
.globl	InitGame	
InitGame:
	objPtr	.req	r2	
	px	.req	r3
	py	.req	r4

	ldr	r2,	=pawns_m
	mov	px,	#16
	mov	py,	#3
	strb	px,	[objPtr]
	strb	py,	[objPtr, #1]
	add	objPtr,	#8

	mov	px,	#15
	mov	py,	#20
	strb	px,	[objPtr]
	strb	py,	[objPtr, #1]
	add	objPtr,	#8

	mov	px,	#4
	mov	py,	#12
	strb	px,	[objPtr]
	strb	py,	[objPtr, #1]
	add	objPtr,	#8

	mov	px,	#28
	mov	py,	#13
	strb	px,	[objPtr]
	strb	py,	[objPtr, #1]
	add	objPtr,	#8

	mov	px,	#6
	mov	py,	#5
	strb	px,	[objPtr]
	strb	py,	[objPtr, #1]
	add	objPtr,	#8

	mov	px,	#26
	mov	py,	#7
	strb	px,	[objPtr]
	strb	py,	[objPtr, #1]
	add	objPtr,	#8

	mov	px,	#4
	mov	py,	#20
	strb	px,	[objPtr]
	strb	py,	[objPtr, #1]
	add	objPtr,	#8

	mov	px,	#23
	mov	py,	#19
	strb	px,	[objPtr]
	strb	py,	[objPtr, #1]
	add	objPtr,	#8

	mov	px,	#7
	mov	py,	#10
	strb	px,	[objPtr]
	strb	py,	[objPtr, #1]
	add	objPtr,	#8

	mov	px,	#20
	mov	py,	#14
	strb	px,	[objPtr]
	strb	py,	[objPtr, #1]
	add	objPtr,	#8

	.unreq	objPtr
	.unreq	px	
	.unreq 	py	

	bx	lr

/* Updates the positions of all game objects */
UpdateScene:
	//bl	UpdateAI
	//bl	UpdatePlayerBullet
	//bl	UpdateEnemyBullets	
	bx	lr
	
/* Draw all objects */
DrawScene:
	push	{r4-r5,	lr}

	mov	r6,	#0
	mov	r1,	#0
	mov	r2,	#0
	ldr	r3,	=0xFFFF
	ldr	r4,	=1023
	ldr	r5,	=767
	push	{r1-r5}
	bl	DrawEmptyRectangle
	pop	{r1-r5}

	count	.req	r6
	numObj	.req	r7
	objPtr	.req	r8

	mov	count,	#0
	ldr	numObj,	=NumOfObjects
	ldr	numObj,	[numObj]
	ldr	objPtr,	=pawns_m
drawLoop:				// draw each object
	ldrb	r1,	[objPtr]
	lsl	r1,	#5
	ldrb	r2,	[objPtr, #1]
	lsl	r2,	#5
	ldrh	r3,	[objPtr, #6]
	ldrb	r4,	[objPtr, #2]
	ldrb	r5,	[objPtr, #3]
	push	{r1-r5}			// store vars on stack
	bl	DrawEmptyRectangle
	pop	{r1-r5}

	add	count,	#1
	add	objPtr,	#OBJSIZE
	cmp	count,	numObj
	bLT	drawLoop

	ldr	r0,	=scoreStr
	mov	r1,	#0
	mov	r2,	#0
	ldr	r3,	=0x7E0
	bl	DrawString

	pop	{r4-r5, pc}
	
/* Checks if a position has an obstacle or object */
ValidMove:	// (int x, int y) : bool
	push	{r4}
	addr	.req	r2
	count	.req	r3
	numObj	.req	r4
	px	.req	r5
	py	.req	r6
	result	.req	r7
	
	mov	result,	#0
	cmp	r0,	#0
	blt	vmdone
	cmp	r0,	#MAX_X
	bge	vmdone
	cmp	r1,	#0
	blt	vmdone
	cmp	r1,	#MAX_Y
	bge	vmdone
	
	mov	result,	#1
	ldr	r3,	=NumOfObjects
	ldr	r3,	[r3]
	ldr	addr,	=pawns_m
vmloop:			// loop through all objects
	cmp	count,	numObj
	bge	vmdone
	ldr	px,	[addr, #OBJ_X]
	cmp	r0,	px
	bne	vmloopinc
	ldr	py,	[addr, #OBJ_Y]
	cmp	r1,	py
	mov	result,	#0	// if any object is the same position, then move is invalid
	beq	vmdone
vmloopinc:
	add	addr,	#OBJSIZE
	add	count,	#1
	b	vmloop
vmdone:
	.unreq	addr
	.unreq	count
	.unreq	numObj
	.unreq	px
	.unreq	py
	mov	r0,	result
	.unreq	result
	bx	lr

/* Return x, y, offset by the direction */
// (x, y, dir): new x, new y      on stack
OffsetPosition:	
	px	.req	r4
	py	.req	r5
	dir	.req	r6
	
	pop	{r0-r2}
	tst	dir,	#1
	subne	py,	#1
	
	tst	dir,	#2
	addne	px,	#1
	
	tst	dir,	#4
	addne	py,	#1

	tst	dir,	#8
	subne	px,	#1

	.unreq	px
	.unreq	py
	.unreq	dir
	push {r0,r1}
	bx	lr

/* Checks if obj1 occupies the same spot as obj2 */
.globl	DetectHit	//(obj1_m, obj2_m)	pointers
DetectHit:	
	obj1_m	.req	r0
	obj2_m	.req	r1
	v1	.req	r2
	v2	.req	r3

	ldrb	v1,	[obj1_m]
	ldrb	v2,	[obj2_m]
	cmp	v1,	v2
	movne	r0,	#0	// no hit
	bne	hitdone
	
	ldrb	v1,	[obj1_m, #1]
	ldrb	v2,	[obj2_m, #1]
	cmp	v1,	v2
	movne	r0,	#0	// no hit
	bne	hitdone

	mov	r0,	#1	// hit detected
hitdone:
	.unreq	obj1_m
	.unreq	obj2_m
	.unreq	v1
	.unreq	v2	
	bx	lr

.section .data

scoreStr:
	.asciz	"SCORE:"

.align 4
GameState:
	.byte	0	// menu_off, menu_on
	.int	0	// normal, won, lost, restart, quit
Score:
	.int	100
pawns_m:
	.rept	10	// 10 pawns
	.byte	0	// x
	.byte	0	// y
	.byte 	8	// w	
	.byte 	16	// h
	.byte	1	// hitpoints
	.byte	5	// value 
	.hword	0xFFE0	// color
	.endr
knights_m:
	.rept	5	// 5 knights
	.byte	16	// x
	.byte	0	// y
	.byte 	16	// w	
	.byte 	24	// h
	.byte	4	// hitpoints
	.byte	10	// value 
	.hword	0xF800	// color
	.endr
queens_m:
	.rept	2	// 2 queens
	.byte	0	// x
	.byte	0	// y
	.byte 	24	// w	
	.byte 	32	// h
	.byte	10	// hitpoints
	.byte	100	// value 
	.hword	0x39C7	// color
	.endr
obstacles_m:		
	.rept	30
	.byte	0	// x
	.byte	0	// y
	.byte 	32	// w	
	.byte 	32	// h
	.byte	10	// hitpoints
	.byte	0	// value 
	.hword	0xFFFF	// color
	.endr
NumOfObjects:
	.int	(.-pawns_m) / OBJSIZE	// 8 bytes per object
bullets_m:		
	.rept	18	// 1 bullet allocated for each object
	.byte	0	// x
	.byte	0	// y
	.byte 	32	// w	
	.byte 	32	// h
	.byte	0	// direction
	.byte	0	// flags
	.hword	0xFFFF	// color
	.endr
