.section .text

.globl	UpdateAI
UpdateAI:
	push	{lr}
/*
	count	.req	r4
	num	.req	r5
	obj_m	.req	r6
	bul_m	.req	r7
	temp	.req	r8
	rand	.req	r9

	mov	count,	#0
	mov	num,	#NUM_PA
	add	num,	#NUM_KN
	add	num,	#NUM_QU
	ldr	obj_m,	=pawns_m
	ldr	bul_m,	=bullets_m
ailoop:
	cmp	count,	num
	bge	aidone

	mov	rand,	count
	mul	rand,	rand

	ldrb	r0,	[bul_m, #BUL_FLG]	// shoot if bullet is non-active
	tst	r0,	#1
	beq	aishoot		

	ldrb	r0,	[r6, #OBJ_X]
	ldrb	r1,	[r6, #OBJ_Y]
	mov	r2,	dir			// make dir random
	bl	OffsetPosition
	mov	dir,	r0	
	bl	MoveObject
aishoot:
	add	count,	#1
	add	obj_m,	#OBJ_SIZE
	add	bul_m,	#BUL_SIZE
	b	ailoop
aidone:*/
	pop	{pc}

.section .data
