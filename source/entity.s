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
	push	{r4-r7, lr}
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
	ldr	addr,	=pawns_m	// starting with the first object
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
	pop	{r4-r7, pc}

.globl	FireBullet
/* Intialize a bullet 
 *	r0 - address of bullet owner object
 *	r1 - direction of bullet (use 4 LSB, 0001 = Up, 0010 = Right, 0100 = Down, 0001 = Left)
 */
FireBullet:		// (int ownerObj, int dir)	
	push	{r4-r7,lr}
	owner	.req	r0
	dir	.req	r1
	addr	.req	r2
	offs	.req	r3
	px	.req	r4
	py	.req	r5
	index	.req	r6
	ldrb	index,	[owner, #OBJ_IDX]

	ldr	addr,	=pBullet_m
	mov	r7, 	#BUL_SIZE	
	mla	addr,	index,	r7,	addr
	
	.unreq	offs
	
	ldrb	px,	[owner, #OBJ_X]	// x
	ldrb	py,	[owner, #OBJ_Y]	// y 		

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
	
	pop	{r4-r7,pc}
	
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
