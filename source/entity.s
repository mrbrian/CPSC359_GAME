.include "constants.s"

.section .text

/* Checks if a position has an obstacle or object */
.globl	ValidObjectMove
ValidObjectMove:	// (int x, int y) : bool
	push	{r4-r7, lr}
	addr	.req	r2
	count	.req	r3
	numObj	.req	r4
	px	.req	r5
	py	.req	r6
	result	.req	r7
	
	mov	result,	#0
	cmp	r0,	#0
	blt	vmdone
	cmp	r0,	#MAX_PX
	bgt	vmdone
	cmp	r1,	#0
	blt	vmdone
	cmp	r1,	#MAX_PY
	bgt	vmdone
	
	mov	result,	#1
	ldr	numObj,	=NumOfObjects
	ldr	numObj,	[numObj]
	ldr	addr,	=pawns_m
	mov	count,	#0
vmloop:			// loop through all objects
	cmp	count,	numObj
	bge	vmdone
	ldrb	px,	[addr, #OBJ_X]
	cmp	r0,	px
	bne	vmloopinc
	ldrb	py,	[addr, #OBJ_Y]
	cmp	r1,	py
	moveq	result,	#0	// if any object is the same position, then move is invalid
	beq	vmdone
vmloopinc:
	add	addr,	#OBJ_SIZE
	add	count,	#1
	b	vmloop
vmdone:
	mov	r0,	result
	.unreq	addr
	.unreq	count
	.unreq	numObj
	.unreq	px
	.unreq	py
	.unreq	result
	pop	{r4-r7, pc}

/* Intialize a bullet */
.globl	FireBullet
FireBullet:		// (int ownerObj, int dir)	
	push	{r4-r7,lr}
	owner	.req	r0
	dir	.req	r1
	addr	.req	r2
	offs	.req	r3
	px	.req	r4
	py	.req	r5
	index	.req	r6
	ldr	offs,	=player_m	
	ldrb	index,	[offs, #OBJ_IDX]

	ldr	addr,	=bullets_m
	mov	r7, 	#BUL_SIZE	
	mla	addr,	index,	r7,	addr
	
	.unreq	offs
	
	ldrb	px,	[owner, #OBJ_X]	// x
	ldrb	py,	[owner, #OBJ_Y]	// y 	
	
	push	{r0-r2}
	mov	r2,	dir
	mov	r0,	px
	mov	r1,	py
	bl	OffsetPosition
	mov	px,	r0
	mov	py,	r1

	cmp	px,	#0	// is it in area bounds
	blt	fireskip
	cmp	px,	#32	// is it in area bounds
	bGE	fireskip
	cmp	py,	#0	// is it in area bounds
	blt	fireskip
	cmp	py,	#24	// is it in area bounds
	bGE	fireskip
	
	pop	{r0-r2}

	strb	px,	[addr, #BUL_X]	
	strb	py,	[addr, #BUL_Y]	
		
	tst	dir,	#5	// moving up or down?
	movne	r3,	#4	// up/down : bullet width 4
	moveq	r3,	#24	// left/right: bullet width 24
	strb	r3,	[addr, #BUL_W]	
	movne	r3,	#24	// up/down: bullet height 24
	moveq	r3,	#4	// left/right: bullet height 4
	strb	r3,	[addr, #BUL_H]	

	strb	dir,	[addr, #BUL_DIR]	
	mov	r3,	#1	// set active flag on	0=inactive 1=playerbullet 2=enemybullet
	strb	r3,	[addr, #BUL_FLG]	
	
	ldrh	r3,	[owner, #OBJ_CLR]	// same color as owner 
	strh	r3,	[addr, #BUL_CLR]	
fireskip:
	.unreq	owner
	.unreq	dir
	.unreq	addr
	.unreq	px
	.unreq	py
	.unreq	index
	
	pop	{r4-r7,pc}
	
/* Moves an object along cardinal directions according to the LS 4 bits of dir */
.globl	MoveObject	//(int obj_m, byte dir)
MoveObject:
	push	{r4-r7,lr}
	obj_m	.req	r4
	dir	.req	r5
	px	.req	r6
	py	.req	r7

	mov	obj_m,	r0
	mov	dir,	r1
	ldrb	px,	[obj_m, #OBJ_X]
	ldrb	py,	[obj_m, #OBJ_Y]

	mov	r2,	dir
	mov	r0,	px
	mov	r1,	py
	bl	OffsetPosition
	mov	px,	r0
	mov	py,	r1
	bl	ValidObjectMove
	cmp	r0,	#1	// if ValidMove passes
	bne	modone
	strb	px,	[obj_m, #OBJ_X]
	strb	py,	[obj_m, #OBJ_Y]
	strb	dir,	[obj_m, #OBJ_DIR]
modone:
	.unreq	obj_m	
	.unreq	dir	
	.unreq	px	
	.unreq	py	
	pop	{r4-r7,pc}
	
.section .data
