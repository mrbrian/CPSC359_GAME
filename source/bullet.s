.section .text

/* Updates the positions of all bullets */
UpdateBullets:
	// update enemy bullets
	push	{lr}
	addr	.req	r0
	dir	.req	r1
	count	.req	r2
	num	.req	r3
	
	ldr	addr,	=bullets_m
	ldr	num,	=NumOfObjects
	ldr	num,	[num]
	mov	count,	#0
ubLoop:
	cmp	count,	NumOfObjects	// there is 1 bullet per object
	ldr	dir,	[addr]			// r1 = dir
	bl	MoveObject
	add	count,	#1	
	add	addr,	#OBJSIZE
	b	ubLoop
	
	.unreq	addr
	.unreq	dir
	.unreq	count
	.unreq	num	
	pop	{pc}

.section .data