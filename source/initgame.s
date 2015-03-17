.include "constants.s"
.section .text

.globl	InitGame	
/* Resets all game info/objects */
InitGame:
	push	{r4-r10}
	count	.req	r4
	temp	.req	r5
	temp2	.req	r6
	num	.req	r7
	objPtr	.req	r8	
	px	.req	r9
	py	.req	r10

	ldr	r0,	=GameState	
	mov	temp,	#G_NORMAL
	str	temp,	[r0]

	mov	num,	#PLYR_HP
	ldr	temp,	=PlayerPoints	
	str	num,	[temp]
	mov	num,	#NUM_PA
	add	num,	#NUM_KN
	add	num,	#NUM_QU
	add	num,	#1	// +1 for player bullet

	ldr	objPtr,	=pBullet_m
	mov	count,	#0
bulletLoop:
	cmp	count,	num	
	bge	bulletDone

	mov	temp,	#0
	strb	temp,	[objPtr, #BUL_X]
	strb	temp,	[objPtr, #BUL_Y]	
	strb	temp,	[objPtr, #BUL_W]	
	strb	temp,	[objPtr, #BUL_H]	
	strb	temp,	[objPtr, #BUL_DIR]
	strb	temp,	[objPtr, #BUL_FLG]
	strh	temp,	[objPtr, #BUL_CLR]
	add	objPtr,	#BUL_SIZE
	add	count,	#1
	b	bulletLoop
bulletDone:
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
	mov	temp,	#PA_VAL
	strb	temp,	[objPtr, #OBJ_VAL]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_DIR]
	mov	temp,	count
	add	temp,	#1
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
	mov	temp,	#KN_VAL
	strb	temp,	[objPtr, #OBJ_VAL]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_DIR]
	mov	temp,	count
	add	temp,	#11
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
	mov	temp,	#QU_VAL
	strb	temp,	[objPtr, #OBJ_VAL]
	mov	temp,	#0
	strb	temp,	[objPtr, #OBJ_DIR]
	mov	temp,	count
	add	temp,	#16
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
	cmp	count,	#27
	addeq	temp,	#1

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
