.include "constants.s"

.section .text

/* Position the game objects */
.globl	InitGame	
InitGame:
	objPtr	.req	r2	
	px	.req	r3
	py	.req	r4

	ldr	r2,	=pawns_m
	mov	px,	#16
	mov	py,	#3
	strb	px,	[objPtr, #OBJ_X]
	strb	py,	[objPtr, #OBJ_Y]
	add	objPtr,	#OBJ_SIZE

	mov	px,	#15
	mov	py,	#20
	strb	px,	[objPtr, #OBJ_X]
	strb	py,	[objPtr, #OBJ_Y]
	add	objPtr,	#OBJ_SIZE

	mov	px,	#4
	mov	py,	#12
	strb	px,	[objPtr, #OBJ_X]
	strb	py,	[objPtr, #OBJ_Y]
	add	objPtr,	#OBJ_SIZE

	mov	px,	#28
	mov	py,	#13
	strb	px,	[objPtr, #OBJ_X]
	strb	py,	[objPtr, #OBJ_Y]
	add	objPtr,	#OBJ_SIZE

	mov	px,	#6
	mov	py,	#5
	strb	px,	[objPtr, #OBJ_X]
	strb	py,	[objPtr, #OBJ_Y]
	add	objPtr,	#OBJ_SIZE

	mov	px,	#26
	mov	py,	#7
	strb	px,	[objPtr, #OBJ_X]
	strb	py,	[objPtr, #OBJ_Y]
	add	objPtr,	#OBJ_SIZE

	mov	px,	#4
	mov	py,	#20
	strb	px,	[objPtr, #OBJ_X]
	strb	py,	[objPtr, #OBJ_Y]
	add	objPtr,	#OBJ_SIZE

	mov	px,	#23
	mov	py,	#19
	strb	px,	[objPtr, #OBJ_X]
	strb	py,	[objPtr, #OBJ_Y]
	add	objPtr,	#OBJ_SIZE

	mov	px,	#7
	mov	py,	#10
	strb	px,	[objPtr, #OBJ_X]
	strb	py,	[objPtr, #OBJ_Y]
	add	objPtr,	#OBJ_SIZE

	mov	px,	#20
	mov	py,	#14
	strb	px,	[objPtr, #OBJ_X]
	strb	py,	[objPtr, #OBJ_Y]
	add	objPtr,	#OBJ_SIZE

	.unreq	objPtr
	.unreq	px	
	.unreq 	py	

	bx	lr

/* Updates the positions of all game objects */
.globl	UpdateScene
UpdateScene:
	push	{lr}
	//bl	UpdateAI
	//bl	UpdatePlayerBullet
	bl	UpdateEnemyBullets	
	pop	{pc}
	
/* Draw all objects */
.globl	DrawScene
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
	ldr	r7,	=NumOfObjects
	ldr	r7,	[r7]
	ldr	objPtr,	=pawns_m
drawLoop:				// draw each object
	ldrb	r1,	[objPtr, #OBJ_X]
	lsl	r1,	#5
	ldrb	r2,	[objPtr, #OBJ_Y]
	lsl	r2,	#5
	ldrh	r3,	[objPtr, #OBJ_CLR]
	ldrb	r4,	[objPtr, #OBJ_W]
	ldrb	r5,	[objPtr, #OBJ_H]
	push	{r1-r5}			// store vars on stack
	bl	DrawEmptyRectangle
	pop	{r1-r5}

	add	count,	#1
	add	objPtr,	#OBJ_SIZE
	cmp	count,	numObj
	bLT	drawLoop

	ldr	objPtr,	=bullets_m
drawLoop2:				// draw each object
	ldrb	r1,	[objPtr, #BUL_X]
	lsl	r1,	#5
	ldrb	r2,	[objPtr, #BUL_Y]
	lsl	r2,	#5
	ldrh	r3,	[objPtr, #BUL_CLR]
	ldrb	r4,	[objPtr, #BUL_W]
	ldrb	r5,	[objPtr, #BUL_H]
	push	{r1-r5}			// store vars on stack
	bl	DrawEmptyRectangle
	pop	{r1-r5}

	add	count,	#1
	add	objPtr,	#BUL_SIZE
	cmp	count,	numObj
	bLT	drawLoop2

	ldr	r0,	=scoreStr
	mov	r1,	#0
	mov	r2,	#0
	ldr	r3,	=0x7E0
	bl	DrawString

	.unreq	count
	.unreq	numObj
	.unreq	objPtr

	pop	{r4-r5, pc}

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
	beq	actEnd
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

.align 4
GameState:
	.int	0	// menu_off, menu_on
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
	.hword	0xFFFF	// color
.globl	pawns_m
pawns_m:
	.rept	10	// 10 pawns
	.byte	0	// x
	.byte	0	// y
	.byte 	8	// w	
	.byte 	16	// h
	.byte	10	// hitpoints
	.byte	5	// value 
	.byte	0	// facing direction
	.byte	0	// index
	.hword	0xFFE0	// color
	.endr
.globl	knights_m
knights_m:
	.rept	5	// 5 knights
	.byte	16	// x
	.byte	0	// y
	.byte 	16	// w	
	.byte 	24	// h
	.byte	40	// hitpoints
	.byte	10	// value 
	.byte	0	// facing direction
	.byte	0	// index
	.hword	0xF800	// color
	.endr
.globl	queens_m
queens_m:
	.rept	2	// 2 queens
	.byte	0	// x
	.byte	0	// y
	.byte 	24	// w	
	.byte 	32	// h
	.byte	100	// hitpoints
	.byte	100	// value 
	.byte	0	// facing direction
	.byte	0	// index
	.hword	0x39C7	// color
	.endr
obstacles_m:		
	.rept	30
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
