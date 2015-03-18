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
.globl	UpdateBullets
UpdateBullets:
	// update enemy bullets
	push	{r4-r6,lr}
	dir	.req	r1
	count	.req	r4
	num	.req	r5
	addr	.req	r6
	
	ldr	addr,	=pBullet_m
	mov	num,	#NUM_PA
	add	num,	#NUM_KN
	add	num,	#NUM_QU
	add	num,	#1
	mov	count,	#0
ubLoop:
	cmp	count,	num	// there is 1 bullet per object
	bge	ubdone
	mov	r0,	addr
	ldrb	r1,	[addr, #BUL_DIR]	// r1 = dir
	bl	MoveBullet

	add	count,	#1	
	add	addr,	#BUL_SIZE
	b	ubLoop
ubdone:
	.unreq	addr
	.unreq	dir
	.unreq	count
	.unreq	num	
	pop	{r4-r6,pc}

PlayerTakeDamage:
	push	{r4-r10,lr}
	obj_m	.req	r4	// the bullet
	px	.req	r5
	py	.req	r6
	dir	.req	r7
	count	.req	r8
	num	.req	r9
	addr	.req	r10

	ldr	r1,	=PlayerPoints
	ldr	r0,	[r1]
	subs	r0,	#BULLET_DAMAGE
	cmp	r0,	#1		// is player alive
	bge	ptDone
ptDead:					// player is dead
	mov	r0,	#0
	strb	r0,	[addr, #OBJ_HP]
ptDone:
	strb	r0,	[r1]
	mov	r0,	#0
	strb	r0,	[obj_m, #BUL_FLG]	
	.unreq	obj_m	
	.unreq	px	
	.unreq	py	
	.unreq	dir	
	.unreq	count
	.unreq	num	
	.unreq	addr	
	pop	{r4-r10,pc}

EnemyTakeDamage:
	push	{r4-r10,lr}
	obj_m	.req	r4	// the bullet
	px	.req	r5
	py	.req	r6
	dir	.req	r7
	count	.req	r8
	num	.req	r9
	addr	.req	r10

	ldrb	r0,	[addr, #OBJ_W]	
	sub	r0,	#2
	strb	r0,	[addr, #OBJ_W]	
	ldrb	r0,	[addr, #OBJ_H]	
	sub	r0,	#2
	strb	r0,	[addr, #OBJ_H]	

	ldrb	r0,	[addr, #OBJ_HP]
	subs	r0,	#BULLET_DAMAGE
	cmp	r0,	#1		// is object alive
	bge	skipDeath
death:					// give player pts?
	movle	r0,	#0

	ldr	r1,	=pBullet_m
	cmp	obj_m,	r1		// is this the players bullet
	bne	skipDeath
	ldr	r1,	=PlayerPoints	
	ldr	r1,	[r1]
	ldrb	r2,	[addr, #OBJ_VAL]	// if yes, lets give them points
	add	r2,	r1
	ldr	r1,	=PlayerPoints
	str	r2,	[r1]
skipDeath:
	strb	r0,	[addr, #OBJ_HP]	
skipPoints:
	mov	r0,	#0
	strb	r0,	[obj_m, #BUL_FLG]	

	.unreq	obj_m	
	.unreq	px	
	.unreq	py	
	.unreq	dir	
	.unreq	count
	.unreq	num	
	.unreq	addr	
	pop	{r4-r10,pc}

/* Moves a bullet along cardinal directions according to the LS 4 bits of dir */
//(int obj_m, byte dir)
.globl	MoveBullet
MoveBullet:
	push	{r4-r10,lr}
	obj_m	.req	r4	// the bullet
	px	.req	r5
	py	.req	r6
	dir	.req	r7
	count	.req	r8
	num	.req	r9
	addr	.req	r10
	ignore	.req	r11
	
	mov	obj_m,	r0
	mov	dir,	r1
	ldrb	px,	[obj_m, #BUL_X]
	ldrb	py,	[obj_m, #BUL_Y]

	ldr	r11,	=pBullet_m
	cmp	obj_m,	r11
	moveq	ignore,	#0
	movne	ignore,	#1

	mov	r0,	px
	mov	r1,	py
	mov	r2,	dir
	bl	OffsetPosition
	mov	px,	r0
	mov	py,	r1
	bl	ValidBulletMove
	cmp	r0,	#1	// if ValidMove passes
	bne	bulletOff

	mov	r0,	#0
	mov	r1,	obj_m
	bl	DrawBullet

	strb	px,	[obj_m, #BUL_X]
	strb	py,	[obj_m, #BUL_Y]
	strb	dir,	[obj_m, #BUL_DIR]

	mov	r0,	#1
	mov	r1,	obj_m
	bl	DrawBullet

	mov	count,	#0
	ldr	num,	=NumOfObjects
	ldr	num,	[num]
	add	num,	#1
	ldr	addr,	=player_m
mbLoop:
	cmp	count,	num	// loop through all objects, test for collision
	bge	modone

	cmp	ignore,	#0
	beq	doCheck
	cmp	count,	#0	// this is an enemy bullet so, only check for player
	beq	doCheck
	ldr	r0,	=obstacles_m	
	cmp	addr,	r0
	bge	doCheck
	b	dmgSkip
doCheck:
	mov	r0,	obj_m
	mov	r1,	addr
	bl	DetectHit
	cmp	r0,	#1
	bne	dmgSkip
hithit:
	mov	r0,	#0
	mov	r1,	obj_m
	bl	DrawObject
	mov	r0,	#0
	mov	r1,	addr
	bl	DrawObject

	ldr	r0,	=player_m
	cmp	addr,	r0
	bne	else
	bleq	PlayerTakeDamage
	b	endif
else:
	blne	EnemyTakeDamage
endif:
	mov	r0,	#1
	mov	r1,	obj_m
	bl	DrawObject
	mov	r0,	#1
	mov	r1,	addr
	bl	DrawObject
dmgSkip:
	add	count,	#1
	add	addr,	#OBJ_SIZE
	b	mbLoop
bulletOff:
	mov	r0,	#0
	mov	r1,	obj_m
	bl	DrawObject
	mov	r0,	#0
	strb	r0,	[obj_m, #BUL_FLG]
modone:
	.unreq	obj_m	
	.unreq	px	
	.unreq	py
	.unreq	dir	
	.unreq	count
	.unreq	num
	.unreq	addr
	.unreq	ignore
	pop	{r4-r10,pc}

.section .data
