.section .text

/* Intialize a bullet */
FireBullet:		// (int ownerObj, int dir)	
	push	{r4,r5}
	owner	.req	r0
	dir	.req	r1
	addr	.req	r2
	offs	.req	r3
	px	.req	r4
	py	.req	r5
	
	ldr	offs,	=pawns_m	
	sub	offs,	owner,	offs	// find mem offset from base address
	ldr	addr,	=bullets_m	
	add	addr,	offs	// add mem offset to bullets base address
	
	.unreq	offs
	
	ldrb	px,	[owner]	// x
	ldrb	py,	[owner, #1]	// y 	
	
	push	{px, py, dir}
	bl	OffsetPosition
	pop	{px, py}
	
	cmp	px,	#0	// is it in area bounds
	blt	fireskip
	cmp	px,	#32	// is it in area bounds
	bGE	fireskip
	cmp	py,	#0	// is it in area bounds
	blt	fireskip
	cmp	py,	#24	// is it in area bounds
	bGE	fireskip
	
	strb	px,	[addr]	
	strb	py,	[addr, #1]	
		
	tst	dir,	#5	// moving up or down?
	bne	r3,	#4	// up/down : bullet width 4
	beq	r3,	#24	// left/right: bullet width 24
	strb	r3,	[addr, #2]	
	bne	r3,	#24	// up/down: bullet height 24
	beq	r3,	#4	// left/right: bullet height 4
	strb	r3,	[addr, #3]	

	strb	dir,	[addr, #4]	
	mov	r3,	#1	// set active flag on	0=inactive 1=playerbullet 2=enemybullet
	strb	r3,	[addr, #5]	
	
	ldrb	r3,	[owner, #6]	// color
	strh	r3,	[addr, #6]	
	
	mov	r0,	addr	
	bl	MoveObject
fireskip:
	.unreq	owner
	.unreq	dir
	.unreq	addr
	.unreq	px
	.unreq	py
	
	pop	{r4,r5}
	bx	lr
	
/* Moves an object along cardinal directions according to the LS 4 bits of dir */
.globl	MoveObject	//(int obj_m, byte dir)
MoveObject:
	obj_m	.req	r0
	dir	.req	r1
	px	.req	r2
	py	.req	r3

	ldrb	px,	[obj_m]
	ldrb	py,	[obj_m, #1]

	push	{r4-r6}	// pass vars on stack
	push	{r2,r3,r1}	// pass vars on stack
	bl	OffsetPosition
	pop	{r2,r3}	// pop vars from stack
	pop	{r4-r6}	// pass vars on stack
	
	mov	r0,	px
	mov	r1,	py
	bl	ValidMove
	cmp	r0,	#1	// if ValidMove passes
	strbeq	px,	[obj_m]
	strbeq	py,	[obj_m, #1]

	.unreq	obj_m	
	.unreq	dir	
	.unreq	px	
	.unreq	py	

	bx	lr
	
.section .data