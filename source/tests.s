.include "constants.s"

.section .text

testStr:
.asciz	"TEST"
.align 	4

.globl	Tests

Tests:
/*
randtest$:
	ldr	r0,	=CLOCKADDR
	ldr	r0,	[r0]
	bl	Random
	b	randtest$*/
modtest$:
	bl	InitGame
	ldr	r0,	=ptsStr
	mov	r1,	#312
	bl	IntToString
	ldr	r1,	=ptsStr
	ldr	r0,	[r1, #7]
	cmp	r0,	#51
	bne	modtestdone$
	ldr	r0,	[r1, #8]
	cmp	r0,	#49
	bne	modtestdone$
	ldr	r0,	[r1, #9]
	cmp	r0,	#50
	bne	modtestdone$
	b	modtest$
modtestdone$:
alivetest$:
	bl	InitGame
	ldr	r0,	=PlayerPoints
	mov	r1,	#0
	str	r1,	[r0]
	bl	IsPlayerAlive	
	cmp	r0,	#0
	bne	alivetest$
blocktest2$:
/*	bl	InitGame
	ldr	r0,	=pawns_m
	add	r0,	#OBJ_SIZE
	add	r0,	#OBJ_SIZE
	add	r0,	#OBJ_SIZE
	add	r0,	#OBJ_SIZE
	add	r0,	#OBJ_SIZE

	ldrb	r1,	[r0, #OBJ_X]
	ldrb	r2,	[r0, #OBJ_Y]
	cmp	r1, #26
	bne	blocktest2$
	cmp	r2, #7
	bne	blocktest2$

	ldr	r0,	=player_m
	mov	r1,	#26
	strb	r1,	[r0, #OBJ_X]
	mov	r1,	#6
	strb	r1,	[r0, #OBJ_Y]
	mov	r1,	#4
	bl	MoveObject
	ldr	r0,	=player_m
	ldrb	r1, [r0, #OBJ_X]
	cmp	r1, #26
	bne	blocktest2$
	ldrb	r1, [r0, #OBJ_Y]
	cmp	r1, #6
	bne	blocktest2$

numtest$:
	bl	InitGame
	ldr	r0,	=pawns_m
	ldrb	r1,	[r0, #OBJ_IDX]
	cmp	r1,	#0	
	bne	numtest$
	ldr	r0,	=NumOfObjects
	ldr	r1,	[r0]
	cmp	r1, #47
	bne	numtest$
numtest2$:
	bl	InitGame
	ldr	r0,	=pawns_m
	ldrh	r1,	[r0, #OBJ_CLR]
	ldr	r2, 	=0xFFE0
	cmp	r1, 	r2
	bne	numtest2$
/*bullettest$:
	ldr	r0,	=bullets_m
	mov	r1,	#1
	strb	r1,	[r0, #BUL_X]
	mov	r1,	#0
	strb	r1,	[r0, #BUL_Y]
	mov	r1,	#1
	strh	r1,	[r0, #BUL_CLR]	
	mov	r1,	#8
	bl	MoveBullet
	ldr	r0,	=bullets_m
	ldrh	r0,	[r0, #BUL_CLR]
	cmp	r0,	#0
	bne	bullettest$
blocktest$:
	bl	InitGame
	ldr	r0,	=player_m
	mov	r1,	#1
	strb	r1,	[r0, #OBJ_X]
	mov	r1,	#0
	strb	r1,	[r0, #OBJ_Y]
	mov	r1,	#8
	bl	MoveObject
	ldr	r0,	=player_m
	ldrb	r1, [r0, #OBJ_X]
	cmp	r1, #1
	bne	blocktest$
	ldrb	r1, [r0, #OBJ_Y]
	cmp	r1, #0
	bne	blocktest$
firetest$:		// shoot a bullet test
	ldr r0,	=pawns_m	
	mov	r1,	#2
	bl	FireBullet
	ldr	r0,	=bullets_m
	ldrb	r4,	[r0, #BUL_X]
	ldrb	r5,	[r0, #BUL_Y]	
	cmp	r4,	#1
	bne	firetest$
	cmp	r5,	#0
	bne	firetest$
	ldrb	r4,	[r0, #BUL_DIR]
	cmp	r4,	#2
	ldrb	r4,	[r0, #BUL_FLG]
	cmp	r4,	#1
	bne	firetest$
	
	ldr	r0,	=bullets_m
	ldrb	r1,	[r0, #BUL_DIR]
	bl	MoveBullet

	ldr	r0,	=bullets_m
	ldrb	r4,	[r0, #BUL_X]
	ldrb	r5,	[r0, #BUL_Y]	
	cmp	r4,	#2
	bne	firetest$
	cmp	r5,	#0
	bne	firetest$

	ldr	r0,	=bullets_m
	mov	r1,	#4
	bl	MoveBullet

	ldr	r0,	=bullets_m
	ldrb	r4,	[r0, #BUL_X]
	ldrb	r5,	[r0, #BUL_Y]	
	ldrb	r6,	[r0, #BUL_DIR]	
	cmp	r4,	#2
	bne	firetest$
	cmp	r5,	#1
	bne	firetest$
	cmp	r6,	#4
	bne	firetest$

updatetest$:
	bl	UpdateEnemyBullets
	ldr	r0,	=bullets_m
	ldrb	r4,	[r0, #BUL_X]
	cmp	r4,	#2
	bne	updatetest$
	ldrb	r4,	[r0, #BUL_Y]	
	cmp	r4,	#2
	bne	updatetest$
	ldrb	r4,	[r0, #BUL_DIR]
	cmp	r4,	#4
	bne	updatetest$		
	ldrb	r4,	[r0, #BUL_FLG]
	cmp	r4,	#1
	bne	updatetest$	
	
	ldr	r0,	=pawns_m
	mov	r1,	#2
	strb	r1,	[r0, #OBJ_X]
	mov	r1,	#3
	strb	r1,	[r0, #OBJ_Y]

	ldrb	r8,	[r0, #OBJ_HP]
	bl	UpdateEnemyBullets

testo:
	ldr	r0,	=bullets_m
	ldr	r1,	=pawns_m
	bl	DetectHit
	cmp	r0,	#1
	ldr	r1,	=bullets_m
	ldr	r2,	=pawns_m
	bne	skip
	ldr	r0,	=bullets_m
	mov	r1,	#0
	strb	r1,	[r0, #BUL_FLG]

skip:

	ldr	r0,	=pawns_m
	ldrb	r1,	[r0, #OBJ_HP]
	sub	r8,	#10
	cmp	r1,	r8

	bne	updatetest$
	ldr	r0,	=bullets_m
	ldrb	r4,	[r0, #BUL_X]
	cmp	r4,	#2
	bne	updatetest$
	ldrb	r4,	[r0, #BUL_Y]	
	cmp	r4,	#3
	bne	updatetest$
	ldrb	r4,	[r0, #BUL_DIR]
	cmp	r4,	#4
	bne	updatetest$		
	ldrb	r4,	[r0, #BUL_FLG]
	cmp	r4,	#0
	bne	updatetest$		

hittest$:		// bullet hit test

	ldr	r0,	=pawns_m
	mov	r1,	#10
	strb	r1,	[r0, #OBJ_HP]
	mov	r1,	r0
	bl	DetectHit
	cmp	r0,	#1
	bne	hittest$
	bl	InitGame

	ldr	r0,	=pawns_m
	add	r1,	#OBJ_SIZE
	bl	DetectHit
	cmp	r0,	#1
	beq	hittest$
	ldr	r0,	=queens_m
	mov	r1,	#4
	bl	MoveObject
	ldr	r0,	=queens_m
	mov	r1,	#4
	bl	MoveObject
	ldr	r0,	=queens_m
	mov	r1,	#8
	bl	MoveObject*/
testGameLoop:
	b	GameMain



