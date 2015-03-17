.include "constants.s"
.section .text

.globl	GameMain
/*	Controls the input and game loops
*/
GameMain:
	push	{r4-r7,lr}
	bl	InitSNES
	bl	InitGame

	ldr	r4,	=pawns_m
	ldr	r5,	=NumOfObjects
	ldr	r6,	=0xFFFF
	bl	ClearScreen
	bl	DrawScene
loopInit:
	ldr	r3,	=CLOCKADDR	// address of CLO(ck) - 0x20003004
	ldr	r1,	[r3]		// read CLO
	ldr	r0,	=FRAMEDELAY
	bl	Wait
inputLoop:
	ldr	r6,	=0xFFFF
	bl	ReadSNES
	ldr	r1,	=SNESpad	
	ldr	r1,	[r1]	
doUpdate:	
	bl	UpdateMenu	// returns r0 = 0 if menu off
	cmp	r0,	#1
	beq	doDraw	
doPlayer:
	ldr	r0,	=GameState
	ldr	r0,	[r0]
	cmp	r0,	#G_NORMAL	// if game is not Normal state
	beq	normalState
	ldr	r0,	=SNESpad
	ldr	r0,	[r0]
	ldr	r1,	=0xFFFF
	cmp	r0,	r1
	beq	inputClearLoop		// none of the buttons pressed
	bl	InitGame
	b	doDraw
normalState:
	cmp	r7,	#0
	bleq	UpdatePlayer	// r0 = 1 if valid move performed
	ldr	r7,	=GameState
	ldr	r7,	[r7]
	bl	UpdateScene	// r0 = 1 
doDraw:
	//bl	ClearScreen
	//mov	r0,	#1
	//bl	DrawScene
	bl	DrawUI
	bl	DrawMenu
inputClearLoop:	
	ldr	r1,	=MenuState
	ldr	r1,	[r1]
	cmp	r1,	#0
	beq	loopInit

	bl	ReadSNES	
	ldr	r1,	=SNESpad
	ldr	r1,	[r1]	
	cmp	r1,	r6	// if no buttons pressed
	bne	loopInit
	ldr	r0,	=0xFFFF
	bl	Wait
	b	inputClearLoop
haltLoop$:
	b		haltLoop$
	pop	{r4-r7,pc}


.globl	UpdateScene
/* Updates the positions of all game objects */
UpdateScene:
	push	{r4-r5,lr}

	gState	.req	r4

	bl	UpdateAI
	bl	UpdateBullets	

	ldr	r5,	=GameState
	ldr	gState,	[r5]

	bl	IsPlayerAlive		// r0 = 1 if yes
	cmp	r0,	#0
	moveq	gState,	#G_LOSE
	streq	gState,	[r5]
	beq	usDone

	bl	AreEnemiesAlive		// r0 = 1 if yes
	cmp	r0,	#0
	moveq	gState,	#G_WIN
	streq	gState,	[r5]
usDone:
	pop	{r4-r5,pc}

.globl	IsPlayerAlive	
IsPlayerAlive:
	mov	r0,	#1
	ldr	r1,	=PlayerPoints	// if PlayerPoints > 0, then player is alive
	ldr	r1,	[r1]
	cmp	r1,	#0
	movle	r0,	#0		// return 1 if alive, else 0
	bx	lr

/* Iterates through all objects and see if any are alive
 * Returns:
 * 	r0 = 1 if at least one enemy is alive, else 0
*/
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

.globl	DrawObject
/*
 * r0 = doDraw
 * r1 = objPtr
*/
DrawObject:
	push	{r4-r6,lr}

	bgClr	.req	r4
	doDraw	.req	r5
	objPtr	.req	r6

	ldr	bgClr,	=BG_COLOR
	mov	doDraw,	r0
	mov	objPtr,	r1
	mov	r0,	objPtr
	bl	IsActive
	cmp	r0,	#0
	beq	dobDone

	ldrb	r1,	[objPtr, #OBJ_X]
	lsl	r1,	#5
	ldrb	r2,	[objPtr, #OBJ_Y]
	lsl	r2,	#5
	ldrh	r3,	[objPtr, #OBJ_CLR]
	cmp	doDraw,	#0
	moveq	r3,	bgClr
	ldrb	r4,	[objPtr, #OBJ_W]
	ldrb	r5,	[objPtr, #OBJ_H]
	mov	r0,	sp
	push	{r1-r5}			// store vars on stack
	bl	DrawFilledRectangle
	mov	sp,	r0
dobDone:
	.unreq	doDraw
	.unreq	objPtr
	.unreq	bgClr
	pop	{r4-r6,pc}
	
.globl	DrawBullet
/*
 * r0 = doDraw
 * r1 = objPtr
*/
DrawBullet:
	push	{r4-r6,lr}

	bgClr	.req	r4
	doDraw	.req	r5
	objPtr	.req	r6

	ldr	bgClr,	=BG_COLOR
	mov	doDraw,	r0
	mov	objPtr,	r1
	mov	r0,	objPtr
	bl	IsActive
	cmp	r0,	#0
	beq	dDone

	ldrb	r1,	[objPtr, #BUL_X]
	lsl	r1,	#5
	ldrb	r2,	[objPtr, #BUL_Y]
	lsl	r2,	#5
	ldrh	r3,	[objPtr, #BUL_CLR]
	cmp	doDraw,	#0
	moveq	r3,	bgClr
	ldrb	r4,	[objPtr, #BUL_W]
	ldrb	r5,	[objPtr, #BUL_H]
	mov	r0,	sp
	push	{r1-r5}			// store vars on stack
	bl	DrawFilledRectangle
	mov	sp,	r0
dDone:
	.unreq	doDraw
	.unreq	objPtr
	.unreq	bgClr
	pop	{r4-r6,pc}
	
.globl	DrawScene
/* Draws all objects in game world
*/
DrawScene:
	push	{r4-r9,	lr}

	ldr	r3,	=BG_COLOR
	bgClr	.req	r3
	doDraw	.req	r9
	mov	r9,	r0

	mov	r6,	#0
	mov	r1,	#0
	mov	r2,	#0
	ldr	r3,	=0xFFFF
	mov	r4,	#SCR_WIDTH
	mov	r5,	#SCR_HEIGHT
	mov	r0,	sp
	push	{r1-r5}
	bl	DrawEmptyRectangle
	mov	sp,	r0

	count	.req	r6
	numObj	.req	r7
	objPtr	.req	r8

	mov	count,	#0
	ldr	numObj,	=NumOfObjects
	ldr	numObj,	[numObj]
	add	numObj,	#1		// +1 for player
	ldr	objPtr,	=player_m
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
	cmp	doDraw,	#0
	moveq	r3,	bgClr
	ldrb	r4,	[objPtr, #OBJ_W]
	ldrb	r5,	[objPtr, #OBJ_H]
	mov	r0,	sp
	push	{r1-r5}			// store vars on stack
	bl	DrawFilledRectangle
	mov	sp,	r0
drawObjectInc:
	add	count,	#1
	add	objPtr,	#OBJ_SIZE
	b	drawObject
doneObj:
	mov	count,	#0
	ldr	objPtr,	=pBullet_m
	mov	numObj,	#NUM_PA
	add	numObj,	#NUM_KN
	add	numObj,	#NUM_QU
	add	numObj,	#1
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
	cmp	doDraw,	#0
	moveq	r3,	bgClr
	ldrb	r4,	[objPtr, #BUL_W]
	ldrb	r5,	[objPtr, #BUL_H]
	mov	r0,	sp
	push	{r1-r5}			// store vars on stack
	bl	DrawFilledRectangle
	mov	sp,	r0
drawBulletInc:
	add	count,	#1
	add	objPtr,	#BUL_SIZE
	b	drawBullet
doneBul:
	.unreq	bgClr
	.unreq	doDraw
	.unreq	count
	.unreq	numObj
	.unreq	objPtr
	pop	{r4-r9, pc}

/* Draws player score, game title, names
*/
DrawUI:
	push	{r4-r5,lr}

	mov	r1,	#0
	mov	r2,	#0
	ldr	r3,	=0xFFFF
	mov	r4,	#SCR_WIDTH
	mov	r5,	#SCR_HEIGHT
	mov	r0,	sp
	push	{r1-r5}
	bl	DrawEmptyRectangle
	mov	sp,	r0

	ldr	r0,	=ptsStr
	ldr	r1,	=PlayerPoints
	ldr	r1,	[r1]
	bl	IntToString
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

	ldr	r0,	=GameState
	ldr	r0,	[r0]
	cmp	r0,	#G_NORMAL
	beq	gDone

	cmp	r0,	#G_WIN	
	ldreq	r0,	=winStr
	moveq	r1,	#300
	moveq	r2,	#400
	moveq	r3,	#0xF800
	bleq	DrawString

	cmp	r0,	#G_LOSE
	ldreq	r0,	=loseStr
	moveq	r1,	#300
	moveq	r2,	#400
	moveq	r3,	#0xF800
	bleq	DrawString
gDone:
	pop	{r4-r5,pc}

.globl	OffsetPosition
/* Returns (x, y) offset by the direction 
 * r0 = x
 * r1 = y
 * r2 = dir
 * Returns:
 *	r0 = new x
 *	r1 = new y
*/
OffsetPosition:	
	px	.req	r0
	py	.req	r1
	dir	.req	r2
	
	tst	dir,	#1
	subne	py,	#1
	bne	offsDone

	tst	dir,	#2
	addne	px,	#1
	bne	offsDone
	
	tst	dir,	#4
	addne	py,	#1
	bne	offsDone

	tst	dir,	#8
	subne	px,	#1
offsDone:
	.unreq	px
	.unreq	py
	.unreq	dir
	bx	lr
	
.globl	IsActive
/* Checks if obj_m is an active object 
 * r0 = object
*/
IsActive:
	obj_m	.req	r0
	result	.req	r3

	mov	result,	#1
	ldr	r1,	=pBullet_m
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
	movne	r0,	#0	// if x1 != x2, no hit
	bne	hitdone
	
	ldrb	r2,	[obj1_m, #OBJ_Y]
	ldrb	r3,	[obj2_m, #OBJ_Y]
	cmp	r2,	r3
	movne	r0,	#0	// if y1 != y2, no hit
	bne	hitdone

	mov	r0,	obj1_m
	bl	IsActive
	cmp	r0,	#0	// if object1 is non-active, no hit
	moveq	r0,	#0	
	beq	hitdone

	mov	r0,	obj2_m
	bl	IsActive
	cmp	r0,	#0	// if object2 is non-active, no hit
	moveq	r0,	#0	
	beq	hitdone

	mov	r0,	#1	// else, hit detected
hitdone:
	.unreq	obj1_m
	.unreq	obj2_m
	pop	{r4,r5,pc}

.section .data

scoreStr:
	.ascii	"SCORE: "
.globl	ptsStr
ptsStr:
	.asciz	"2000111333"	// where score string is held
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
.globl	GameState
GameState:
	.int	0	// normal, won, lost, restart, quit
.globl PlayerPoints
PlayerPoints:
	.int	PLYR_HP	// player score - also used as players hp when taking damage
.globl	player_m
player_m:
	.byte	0	// x
	.byte	0	// y
	.byte 	32	// w	
	.byte 	32	// h
	.byte	PLYR_HP	// hitpoints
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
.globl	obstacles_m
obstacles_m:		
	.rept	NUM_OBS
	.byte	0	// x
	.byte	0	// y
	.byte 	32	// w	
	.byte 	32	// h
	.byte	OBS_HP	// hitpoints
	.byte	0	// value 
	.byte	0	// facing direction
	.byte	0	// index
	.hword	0xFFFF	// color
	.endr
.align	4
.globl	NumOfObjects
NumOfObjects:
	.int	(.-pawns_m) / OBJ_SIZE	// 10 bytes per object
.globl	pBullet_m	
pBullet_m:		// memory for player's bullet
	.byte	0	// x
	.byte	0	// y
	.byte 	32	// w	
	.byte 	32	// h
	.byte	0	// direction
	.byte	0	// flags
	.hword	0xFFFF	// color
.globl	eBullets_m
eBullets_m:		
	.rept	17	// 1 bullet allocated for each enemy
	.byte	0	// x
	.byte	0	// y
	.byte 	32	// w	
	.byte 	32	// h
	.byte	0	// direction
	.byte	0	// flags
	.hword	0xFFFF	// color
	.endr
