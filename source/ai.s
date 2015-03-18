.include "constants.s"
.section .text

.globl	UpdateAI
/* Moves enemies and make them shoot
*/
UpdateAI:
	push	{r4-r8,lr}

	count	.req	r4
	num	.req	r5
	obj_m	.req	r6
	bul_m	.req	r7
	temp	.req	r8

	mov	count,	#0
	mov	num,	#NUM_PA
	add	num,	#NUM_KN
	add	num,	#NUM_QU
	ldr	obj_m,	=pawns_m
	ldr	bul_m,	=eBullets_m
aiLoop:
	cmp	count,	num
	bge	aiDone

	mov	r0,	obj_m
	bl	IsActive
	cmp	r0,	#0
	beq	aiInc

	ldrb	r0,	[bul_m, #BUL_FLG]	// shoot if bullet is non-active
	cmp	r0,	#0
	beq	aiShoot		

	bl	RandomDirection
	mov	r1,	r0
	mov	r0,	obj_m
/*	ldr	r1,	=player_m
	ldrb	r1,	[r1, count]
	and	r1,	#0b1111
*/
	bl	MoveObject
	b	aiInc
aiShoot:	
	bl	RandomDirection
	mov	r1,	r0
	mov	r0,	obj_m	
	bl	FireBullet
aiInc:
	add	obj_m,	#OBJ_SIZE
	add	bul_m,	#BUL_SIZE
	add	count,	#1
	b	aiLoop
aiDone:
	.unreq	count	
	.unreq	num	
	.unreq	obj_m	
	.unreq	bul_m	
	.unreq	temp	
	pop	{r4-r8,pc}

.section .data
