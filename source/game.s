.include "constants.s"

.section .text

/* Initialize position and stats of all game objects */
.globl	InitGame	
InitGame:
	push	{r4-r10}
	count	.req	r4
	temp	.req	r5
	temp2	.req	r6
	num	.req	r7
	objPtr	.req	r8	
	px	.req	r9
	py	.req	r10

	ldr	objPtr,	=player_m
	mov	temp,	#32
	strb	temp,	[objPtr, #OBJ_W]	
	mov	temp,	#32
	strb	temp,	[objPtr, #OBJ_H]	
	mov	temp,	#PLYR_HP
	strb	temp,	[objPtr, #OBJ_HP]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_VAL]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_DIR]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_IDX]
	ldr	temp,	=PLYR_CLR
	strh	temp,	[objPtr, #OBJ_CLR]

	mov	count,	#0
	ldr	objPtr,	=pawns_m
pawnloop:
	cmp	count,	#NUM_PA	
	bge	pawndone
	
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_X]	
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_Y]	
	mov	temp,	#8
	strb	temp,	[objPtr, #OBJ_W]	
	mov	temp,	#16
	strb	temp,	[objPtr, #OBJ_H]	
	mov	temp,	#PA_HP
	strb	temp,	[objPtr, #OBJ_HP]
	mov	temp,	#5
	strb	temp,	[objPtr, #OBJ_VAL]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_DIR]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_IDX]
	ldr	temp,	=0xFFE0
	strh	temp,	[objPtr, #OBJ_CLR]

	add	objPtr,	#OBJ_SIZE
	add	count,	#1
	b	pawnloop
pawndone:
	mov	count,	#0
	ldr	objPtr,	=knights_m
knightloop:
	cmp	count,	#NUM_KN	
	bge	knightdone	

	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_X]	
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_Y]	
	mov	temp,	#16
	strb	temp,	[objPtr, #OBJ_W]	
	mov	temp,	#24
	strb	temp,	[objPtr, #OBJ_H]	
	mov	temp,	#KN_HP
	strb	temp,	[objPtr, #OBJ_HP]
	mov	temp,	#10
	strb	temp,	[objPtr, #OBJ_VAL]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_DIR]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_IDX]
	ldr	temp,	=0xF800
	strh	temp,	[objPtr, #OBJ_CLR]

	add	objPtr,	#OBJ_SIZE
	add	count,	#1
	b	knightloop
knightdone:
	mov	count,	#0
	ldr	objPtr,	=queens_m
queenloop:
	cmp	count,	#NUM_QU
	bge	queendone	

	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_X]	
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_Y]	
	mov	temp,	#24
	strb	temp,	[objPtr, #OBJ_W]	
	mov	temp,	#32
	strb	temp,	[objPtr, #OBJ_H]	
	mov	temp,	#QU_HP
	strb	temp,	[objPtr, #OBJ_HP]
	mov	temp,	#100
	strb	temp,	[objPtr, #OBJ_VAL]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_DIR]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_IDX]
	ldr	temp,	=0x39C7
	strh	temp,	[objPtr, #OBJ_CLR]

	add	objPtr,	#OBJ_SIZE
	add	count,	#1
	b	queenloop
queendone:
	mov	count,	#0
	ldr	objPtr,	=obstacles_m
obsloop:				// obstacles
	cmp	count,	#NUM_OBS	
	bge	obsdone	
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_X]	
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_Y]	
	mov	temp,	#32
	strb	temp,	[objPtr, #OBJ_W]	
	mov	temp,	#32
	strb	temp,	[objPtr, #OBJ_H]	
	mov	temp,	#OBS_HP
	strb	temp,	[objPtr, #OBJ_HP]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_VAL]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_DIR]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_IDX]
	ldr	temp,	=0xFFFF
	strh	temp,	[objPtr, #OBJ_CLR]

	add	objPtr,	#OBJ_SIZE
	add	count,	#1
	b	obsloop
obsdone:
	mov	count,	#0
	ldr	objPtr,	=player_m
	ldr	num,	=NumOfObjects
	ldr	num,	[num]
	add	num, 	#1
placeloop:
	cmp	count,	num	
	bge	placedone	

	mov	r0,	#43
	mul	temp,	count,	r0
	mul	temp,	temp
	mov	r0,	#0
mod_x:
	cmp	temp,	#MAX_PX
	blt	mod_y
	sub	temp, 	#MAX_PX
	add	r0,	#1	
	b	mod_x
mod_y:
	cmp	r0,	#MAX_PY
	blt	mod_done
	sub	r0, 	#MAX_PY
	b	mod_y
mod_done:
/*
	mov	r0,	temp
	mov	r1,	r7
	bl	ValidObjectMove
	cmp	r0,	#0
	bne	skip
fart:
	mov	r0,	#0
skip:*/
	strb	temp,	[objPtr, #OBJ_X]	
	mov	temp,	r0
	strb	temp,	[objPtr, #OBJ_Y]	
	add	objPtr,	#OBJ_SIZE
	add	count,	#1
	b	placeloop
placedone:
	.unreq	objPtr
	.unreq	px	
	.unreq 	py	
	.unreq	count
	.unreq	temp
	.unreq	temp2
	.unreq	num
	pop	{r4-r10}
	bx	lr

.globl	GameMain
GameMain:
	bl	InitSNES
	bl	InitGame

	ldr	r4,	=pawns_m
	ldr	r5,	=NumOfObjects
	ldr	r6,	=0xFFFF
	bl	ClearScreen
	bl	DrawScene
	bl	DrawPlayer
inputLoop:
	ldr	r6,	=0xFFFF
	bl	ReadSNES
	ldr	r1,	=SNESpad	
	ldr	r1,	[r1]	
	cmp	r1,	r6	// if no buttons pressed
	beq	inputLoop
doupdate:	
	bl	UpdatePlayer	// r0 = 1 if valid move performed
	cmp	r0,	#0
	beq	checkstart	// check if start pressed

	ldr	r7,	=GameState
	ldr	r7,	[r7]
dodraw:
	bl	ClearScreen
	bl	UpdateScene	// r0 = 1 
	bl	DrawScene
	bl	DrawPlayer
	ldr	r0,	=MenuState
	ldr	r0,	[r0]
	cmp	r0,	#0
	blne	DrawMenu
	b	inputClearLoop
checkstart:
	ldr	r1,	=SNESpad	// detect start button 
	ldr	r1,	[r1]
	tst	r1,	#0b1000	
	blne	inputClearLoop
	ldr	r1,	=MenuState
	ldr	r0,	[r1]
	cmp	r0,	#0
	bne	menuoff	
	mov	r0,	#1
	str	r0,	[r1]
	b	dodraw	
menuoff:
	mov	r0,	#0
	str	r0,	[r1]
	b	dodraw	
inputClearLoop:	
	bl	ReadSNES	
	ldr	r1,	=SNESpad
	ldr	r1,	[r1]	
	cmp	r1,	r6	// if no buttons pressed
	bne	inputClearLoop
	ldr	r0,	=0xFFFF
	bl	Wait
	b	inputLoop
haltLoop$:
	b		haltLoop$

/* Updates the positions of all game objects */
.globl	UpdateScene
UpdateScene:
	push	{lr}

	gState	.req	r4

	bl	UpdateAI
	//bl	UpdatePlayerBullet
	bl	UpdateEnemyBullets	

	ldr	r5,	=GameState
	ldr	gState,	[r5]

	cmp	gState,	#0	// if game is not Normal state
	bne	dostate		// skip changing state

	bl	IsPlayerAlive		// r0 = 1 if yes
	cmp	r0,	#0
	moveq	gState,	#G_LOSE
	streq	gState,	[r5]
	beq	dostate

	bl	AreEnemiesAlive		// r0 = 1 if yes
	cmp	r0,	#0
	moveq	gState,	#G_WIN
	streq	gState,	[r5]

dostate:
	cmp	gState,	#G_NORMAL
	beq	gDone

	cmp	gState,	#G_WIN	
	ldr	r0,	=winStr
	moveq	r1,	#300
	moveq	r2,	#400
	moveq	r3,	#0xF800
	bleq	DrawString

	cmp	gState,	#G_LOSE
	ldr	r0,	=loseStr
	moveq	r1,	#300
	moveq	r2,	#400
	moveq	r3,	#0xF800
	bleq	DrawString
gDone:
	pop	{pc}

.globl	IsPlayerAlive	
IsPlayerAlive:
	mov	r0,	#1
	ldr	r1,	=player_m
	ldr	r1,	[r1, #OBJ_HP]
	cmp	r1,	#0
	movle	r0,	#0
	bx	lr

AreEnemiesAlive:
	push	{r4-r8}
	ePtr	.req	r4
	count	.req	r5
	num	.req	r6
	result	.req	r7

	mov	r8,	#0
	mov	result,	#0
	ldr	ePtr,	=pawns_m
	mov	count,	#0
	mov	num,	#NUM_PA
	add	num,	#NUM_KN
	add	num,	#NUM_QU
eloop:
	cmp	count,	num
	bge	edone
	
	ldrb	r8,	[ePtr, #OBJ_HP]
	cmp	r8,	#1
	movge	result,	#1
	bge	edone
	add	ePtr,	#OBJ_SIZE
	add	count,	#1
	b	eloop
edone:
	mov	r0,	result

	.unreq	ePtr
	.unreq	count
	.unreq	num
	.unreq	result
	pop	{r4-r8}
	bx	lr

/* Draw all objects */
.globl	DrawScene
DrawScene:
	push	{r4-r8,	lr}

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
drawObject:				// draw each object
	cmp	count,	numObj
	bge	doneObj

	mov	r0,	objPtr
	bl	IsActive
	cmp	r0,	#0
	beq	drawObjectInc

	ldrb	r1,	[objPtr, #OBJ_X]
	lsl	r1,	#5
	ldrb	r2,	[objPtr, #OBJ_Y]
	lsl	r2,	#5
	ldrh	r3,	[objPtr, #OBJ_CLR]
	ldrb	r4,	[objPtr, #OBJ_W]
	ldrb	r5,	[objPtr, #OBJ_H]
	push	{r1-r5}			// store vars on stack
	bl	DrawFilledRectangle
	pop	{r1-r5}
drawObjectInc:
	add	count,	#1
	add	objPtr,	#OBJ_SIZE
	b	drawObject
doneObj:
	mov	count,	#0
	ldr	objPtr,	=bullets_m
	mov	numObj,	#NUM_PA
	add	numObj,	#NUM_KN
	add	numObj,	#NUM_QU
drawBullet:				// draw each object
	cmp	count,	numObj
	bge	doneBul

	mov	r0,	objPtr
	bl	IsActive
	cmp	r0,	#0
	beq	drawBulletInc

	ldrb	r1,	[objPtr, #BUL_X]
	lsl	r1,	#5
	ldrb	r2,	[objPtr, #BUL_Y]
	lsl	r2,	#5
	ldrh	r3,	[objPtr, #BUL_CLR]
	ldrb	r4,	[objPtr, #BUL_W]
	ldrb	r5,	[objPtr, #BUL_H]
	push	{r1-r5}			// store vars on stack
	bl	DrawFilledRectangle
	pop	{r1-r5}
drawBulletInc:
	add	count,	#1
	add	objPtr,	#BUL_SIZE
	b	drawBullet
doneBul:
	ldr	r0,	=scoreStr
	mov	r1,	#0
	mov	r2,	#0
	ldr	r3,	=0x7E0
	bl	DrawString
	ldr	r0,	=titleStr
	mov	r1,	#0
	mov	r2,	#15
	ldr	r3,	=0x7E0
	bl	DrawString
	ldr	r0,	=brianStr
	mov	r1,	#0
	mov	r2,	#30
	ldr	r3,	=0x7E0
	bl	DrawString
	ldr	r0,	=ianStr
	mov	r1,	#0
	mov	r2,	#45
	ldr	r3,	=0x7E0
	bl	DrawString

	.unreq	count
	.unreq	numObj
	.unreq	objPtr

	pop	{r4-r8, pc}

/* Return x, y, offset by the direction */
// (r0 = x, r1 = y, r2 = dir)
.globl	OffsetPosition
OffsetPosition:	
	px	.req	r0
	py	.req	r1
	dir	.req	r2
	
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
	bx	lr
	
/* Checks if obj_m is an active object */
IsActive:
	obj_m	.req	r0
	result	.req	r3

	mov	result,	#1
	ldr	r1,	=bullets_m
	cmp	r0,	r1
	
	bge	actBul
	ldrb	r2,	[r0,	#OBJ_HP]
	cmp	r2,	#0
	movle	result,	#0
	b	actEnd
actBul:
	ldrb	r2,	[r0,	#BUL_FLG]
	cmp	r2,	#0
	moveq	result,	#0
	beq	actEnd
actEnd:
	mov	r0,	result
	.unreq	obj_m
	.unreq	result
	bx	lr

/* Checks if obj1 occupies the same spot as obj2 */
.globl	DetectHit	//(obj1_m, obj2_m)	pointers
DetectHit:
	push	{r4,r5,lr}
	obj1_m	.req	r4
	obj2_m	.req	r5

	mov	r4,	r0
	mov	r5,	r1
	
	ldrb	r2,	[obj1_m, #OBJ_X]
	ldrb	r3,	[obj2_m, #OBJ_X]
	cmp	r2,	r3
	movne	r0,	#0	// no hit
	bne	hitdone
	
	ldrb	r2,	[obj1_m, #OBJ_Y]
	ldrb	r3,	[obj2_m, #OBJ_Y]
	cmp	r2,	r3
	movne	r0,	#0	// no hit
	bne	hitdone

	mov	r0,	obj1_m
	bl	IsActive
	cmp	r0,	#0	// no hit
	moveq	r0,	#0	// no hit
	beq	hitdone

	mov	r0,	obj2_m
	bl	IsActive
	cmp	r0,	#0	// no hit
	moveq	r0,	#0	// no hit
	beq	hitdone

	mov	r0,	#1	// hit detected
hitdone:
	.unreq	obj1_m
	.unreq	obj2_m
	pop	{r4,r5,pc}

.section .data

scoreStr:
	.asciz	"SCORE:"
titleStr:
	.asciz	"BOX KILLER"
brianStr:
	.asciz	"Brian Yee"
ianStr:
	.asciz	"Ian Eliopoulos"
winStr:	
	.asciz	"YOU WIN"
loseStr:
	.asciz	"YOU LOSE"

.align 4
GameState:
	.int	0	// normal, won, lost, restart, quit
Score:
	.int	100
.globl	player_m
player_m:
	.byte	0	// x
	.byte	0	// y
	.byte 	32	// w	
	.byte 	32	// h
	.byte	100	// hitpoints
	.byte	0	// value 
	.byte	0	// facing direction
	.byte	0	// index
	.hword	0x7E0	// color
.globl	pawns_m
pawns_m:
	.rept	NUM_PA	// 10 pawns
	.byte	0	// x
	.byte	0	// y
	.byte 	8	// w	
	.byte 	16	// h
	.byte	PA_HP	// hitpoints
	.byte	5	// value 
	.byte	0	// facing direction
	.byte	0	// index
	.hword	0xFFE0	// color
	.endr
.globl	knights_m
knights_m:
	.rept	NUM_KN	// 5 knights
	.byte	16	// x
	.byte	0	// y
	.byte 	16	// w	
	.byte 	24	// h
	.byte	KN_HP	// hitpoints
	.byte	10	// value 
	.byte	0	// facing direction
	.byte	0	// index
	.hword	0xF800	// color
	.endr
.globl	queens_m
queens_m:
	.rept	NUM_QU	// 2 queens
	.byte	0	// x
	.byte	0	// y
	.byte 	24	// w	
	.byte 	32	// h
	.byte	QU_HP	// hitpoints
	.byte	100	// value 
	.byte	0	// facing direction
	.byte	0	// index
	.hword	0x39C7	// color
	.endr
obstacles_m:		
	.rept	NUM_OBS
	.byte	0	// x
	.byte	0	// y
	.byte 	32	// w	
	.byte 	32	// h
	.byte	100	// hitpoints
	.byte	0	// value 
	.byte	0	// facing direction
	.byte	0	// index
	.hword	0xFFFF	// color
	.endr
.align	4
.globl	NumOfObjects
NumOfObjects:
	.int	(.-pawns_m) / OBJ_SIZE	// 10 bytes per object
.globl	bullets_m
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
