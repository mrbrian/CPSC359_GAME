.include "constants.s"

.section .text

.globl	ValidObjectMove
/* Checks if a position has an obstacle or object 
 *	r0 - X coord
 *	r1 - Y coord
 * Returns:
 *	r0 - 1 if valid move, 0 if invalid move
 */
ValidObjectMove:	// (int x, int y) : bool
	push	{r4-r8, lr}
	addr	.req	r2
	count	.req	r3
	numObj	.req	r4
	px	.req	r5
	py	.req	r6
	hp	.req	r7
	result	.req	r8
	
	mov	result,	#0		// check if x,y are within screen borders
	cmp	r0,	#0
	blt	vmdone
	cmp	r0,	#MAX_PX
	bgt	vmdone
	cmp	r1,	#0
	blt	vmdone
	cmp	r1,	#MAX_PY
	bgt	vmdone
	
	mov	result,	#1		// by default return 1
	ldr	numObj,	=NumOfObjects
	ldr	numObj,	[numObj]
	add	numObj,	#1		// +1 for player
	ldr	addr,	=player_m	// starting with the first object
	mov	count,	#0
vmloop:			
	cmp	count,	numObj	// loop through all objects
	bge	vmdone
	ldrb	px,	[addr, #OBJ_X]
	cmp	r0,	px			// if object x = inputX..
	bne	vmloopinc		
	ldrb	py,	[addr, #OBJ_Y]
	cmp	r1,	py		// and if object y = inputY..
	bne	vmloopinc

	ldrb	hp,	[addr, #OBJ_HP]
	cmp	hp,	#1		// and if object is alive..

	movge	result,	#0	// then the move is invalid, return 0
	bge	vmdone
vmloopinc:
	add	addr,	#OBJ_SIZE	// get address of next object
	add	count,	#1	// increment counter
	b	vmloop
vmdone:
	mov	r0,	result	// return result in r0
	.unreq	addr
	.unreq	count
	.unreq	numObj
	.unreq	px
	.unreq	py
	.unreq	hp
	.unreq	result
	pop	{r4-r8, pc}

.globl	FireBullet
/* Intialize a bullet 
 *	r0 - address of bullet owner object
 *	r1 - direction of bullet (use 4 LSB, 0001 = Up, 0010 = Right, 0100 = Down, 0001 = Left)
 */
FireBullet:		// (int ownerObj, int dir)	
	push	{r4-r10,lr}
	owner	.req	r4
	dir	.req	r5
	addr	.req	r6
	offs	.req	r7
	px	.req	r8
	py	.req	r9
	index	.req	r10

	mov	owner,	r0
	mov	dir,	r1
	ldrb	index,	[owner, #OBJ_IDX]

	ldr	addr,	=pBullet_m
	mov	r7, 	#BUL_SIZE	
	mla	addr,	index,	r7,	addr
	
	.unreq	offs

	ldrb	r8,	[addr, #BUL_FLG]	// check if active bullet exists
	cmp	r8,	#1
	moveq	r0,	#0
	moveq	r1,	addr
	bleq	DrawObject

	ldrb	px,	[owner, #OBJ_X]	// x
	ldrb	py,	[owner, #OBJ_Y]	// y 		

	strb	px,	[addr, #BUL_X]	
	strb	py,	[addr, #BUL_Y]	
		
	tst	dir,	#5	// moving up or down?
	movne	r3,	#BULLET_W	// up/down : bullet width 4
	moveq	r3,	#BULLET_H	// left/right: bullet width 24
	strb	r3,	[addr, #BUL_W]	
	movne	r3,	#BULLET_H	// up/down: bullet height 24
	moveq	r3,	#BULLET_W	// left/right: bullet height 4
	strb	r3,	[addr, #BUL_H]	

	strb	dir,	[addr, #BUL_DIR]	
	mov	r3,	#1	// set active flag on	0=inactive 1=active
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
	
	pop	{r4-r10,pc}
	
.globl	MoveObject	
/* Moves an object along cardinal directions according to the LS 4 bits of dir 
 *	r0 - address of object
 *	r1 - direction of bullet (use 4 LSB, 0001 = Up, 0010 = Right, 0100 = Down, 0001 = Left)
 * Returns:
 *	r0 - 1 if valid move, 0 if invalid move
 */
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

	mov	r0,	#0
	mov	r1,	obj_m
	bl	DrawObject

	strb	px,	[obj_m, #OBJ_X]
	strb	py,	[obj_m, #OBJ_Y]
	strb	dir,	[obj_m, #OBJ_DIR]

	mov	r0,	#1
	mov	r1,	obj_m
	bl	DrawObject
modone:
	.unreq	obj_m	
	.unreq	dir	
	.unreq	px	
	.unreq	py	
	pop	{r4-r7,pc}
	
.globl	DrawObject
/*
 * r0 = doDraw
 * r1 = objPtr
*/
DrawObject:
	push	{r4-r6,lr}

	bgClr	.req	r4
	doDraw	.req	r5
	objPtr	.req	r6

	ldr	bgClr,	=BG_COLOR
	mov	doDraw,	r0
	mov	objPtr,	r1
	mov	r0,	objPtr
	bl	IsActive
	cmp	r0,	#0
	beq	dobDone

	ldrb	r1,	[objPtr, #OBJ_X]
	lsl	r1,	#5
	ldrb	r2,	[objPtr, #OBJ_Y]
	lsl	r2,	#5
	ldrh	r3,	[objPtr, #OBJ_CLR]
	cmp	doDraw,	#0
	moveq	r3,	bgClr
	ldrb	r4,	[objPtr, #OBJ_W]
	ldrb	r5,	[objPtr, #OBJ_H]
	mov	r0,	sp
	push	{r1-r5}			// store vars on stack
	bl	DrawCenteredRectangle
	mov	sp,	r0
dobDone:
	.unreq	doDraw
	.unreq	objPtr
	.unreq	bgClr
	pop	{r4-r6,pc}
	
.section .data
