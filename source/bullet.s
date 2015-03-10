.include "constants.s"

.section .text

/* Checks if a position has an obstacle or object */
.globl	ValidBulletMove
ValidBulletMove:	// (int x, int y) : bool
	push	{r4-r7}
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
vmdone:
	.unreq	addr
	.unreq	count
	.unreq	numObj
	.unreq	px
	.unreq	py
	mov	r0,	result
	.unreq	result
	pop	{r4-r7}
	bx	lr

/* Updates the positions of all bullets */
.globl	UpdateEnemyBullets
UpdateEnemyBullets:
	// update enemy bullets
	push	{r4-r6,lr}
	dir	.req	r1
	count	.req	r4
	num	.req	r5
	addr	.req	r6
	
	ldr	addr,	=bullets_m
	mov	num,	#1
	mov	count,	#0
ubLoop:
	cmp	count,	num	// there is 1 bullet per object
	bge	ubdone
	mov	r0,	addr
	ldrb	r1,	[addr, #BUL_DIR]	// r1 = dir
	bl	MoveBullet

	add	count,	#1	
	add	addr,	#OBJSIZE
	b	ubLoop
ubdone:
	.unreq	addr
	.unreq	dir
	.unreq	count
	.unreq	num	
	pop	{r4-r6,pc}

/* Moves a bullet along cardinal directions according to the LS 4 bits of dir */
//(int obj_m, byte dir)
.globl	MoveBullet
MoveBullet:
	push	{r4-r7,lr}
	obj_m	.req	r4
	px	.req	r5
	py	.req	r6
	dir	.req	r7

	mov	obj_m,	r0
	mov	dir,	r1
	ldrb	px,	[obj_m, #BUL_X]
	ldrb	py,	[obj_m, #BUL_Y]

	mov	r0,	px
	mov	r1,	py
	mov	r2,	dir
	bl	OffsetPosition
after2:
	mov	px,	r0
	mov	py,	r1
	bl	ValidBulletMove
	cmp	r0,	#1	// if ValidMove passes
	bne	modone
	strb	px,	[obj_m, #BUL_X]
	strb	py,	[obj_m, #BUL_Y]
	strb	dir,	[obj_m, #BUL_DIR]
modone:
	.unreq	obj_m	
	.unreq	dir	
	.unreq	px	
	.unreq	py
	pop	{r4-r7,pc}

.section .data
