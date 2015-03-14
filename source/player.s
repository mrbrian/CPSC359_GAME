.include "constants.s"
.section .text

.globl	UpdatePlayer
UpdatePlayer:
	push	{r4,lr}
	result	.req	r4
	mov	result,	#0
	ldr	r0,	=SNESpad
	ldr	r0,	[r0]	

	ldr	r1,	=player_m
	ldr	r2,	[r1]
	ldr	r3,	[r1, #4]
shoot:
	tst	r0,	#0b100000000	// a button	
	bne	horz
	mov	r0,	r1
	ldrb	r1,	[r1, #OBJ_DIR]
	bl	FireBullet
	mov	result,	#1
	b	done
horz:
	tst	r0,	#0b1000000	// left
	moveq	r0,	r1	// arg1 = object
	moveq	r1,	#8	// arg2 = direction
	bleq	MoveObject	// returns 1 if valid move
	cmp	r0,	#1
	moveq	result,	#1
	beq	done
	tst	r0,	#0b10000000	// right
	moveq	r0,	r1
	moveq	r1,	#2
	bleq	MoveObject	// returns 1 if valid move
	cmp	r0,	#1
	moveq	result,	#1
	beq	done
vert:
	tst	r0,	#0b10000	// up
	moveq	r0,	r1
	moveq	r1,	#1
	bleq	MoveObject// returns 1 if valid move
	cmp	r0,	#1
	moveq	result,	#1
	beq	done
	tst	r0,	#0b100000	// down
	moveq	r0,	r1
	moveq	r1,	#4
	bleq	MoveObject// returns 1 if valid move
	cmp	r0,	#1
	moveq	result,	#1
	beq	done
done:
	mov	r0,	result
	.unreq	result
	pop	{r4,pc}

.globl	DrawPlayer
DrawPlayer:
	push	{r4,r5,lr}	

	mov	r0,	#TILESIZE
	ldr	r3,	=player_m
	ldrb	r1,	[r3, #OBJ_X]
	lsl	r1,	#5
	ldrb	r2,	[r3, #OBJ_Y]
	lsl	r2,	#5
	ldrb	r4,	[r3, #OBJ_W]
	ldrb	r5,	[r3, #OBJ_H]
	ldrh	r3,	[r3, #OBJ_CLR]
	push	{r1-r5}
	bl	DrawFilledRectangle
	pop	{r1-r5}

	pop	{r4,r5,pc}	

.section .data

