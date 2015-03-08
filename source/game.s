.section .text

.equ	OBJSIZE,	8
.equ	MAX_PX,		31
.equ	MAX_PY,		23

.globl	testGame
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

.globl	InitGame	// position the game objects
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

UpdateScene:
	bx	lr

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

.globl	MoveObject	//(ptr obj_m, byte dir)
MoveObject:
	obj_m	.req	r0
	dir	.req	r1
	px	.req	r2
	py	.req	r3

	ldrb	px,	[obj_m]
	ldrb	py,	[obj_m, #1]
	cmp	py,	#0
	tstne	dir,	#1
	subne	py,	#1
	
	cmp	px,	#MAX_PX
	tstne	dir,	#2
	addne	px,	#1
	
	cmp	py,	#MAX_PY
	tstne	dir,	#4
	addne	py,	#1

	cmp	px,	#0
	tstne	dir,	#8
	subne	px,	#1

	strb	px,	[obj_m]
	strb	py,	[obj_m, #1]

	.unreq	obj_m	
	.unreq	dir	
	.unreq	px	
	.unreq	py	

	bx	lr

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
	.rept	18
	.byte	0	// x
	.byte	0	// y
	.byte 	32	// w	
	.byte 	32	// h
	.byte	0	// direction
	.hword	0xFFFF	// color
	.endr
