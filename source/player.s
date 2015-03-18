.include "constants.s"
.section .text

.globl	UpdatePlayer
/*	Reads the SNES pad input, and performs any movement/firing actions
 * Returns:
 * 	r0 = 1 if user performed a valid action, else 0 
*/
UpdatePlayer:
	push	{r4-r6,lr}
	result	.req	r4
	pAddr	.req	r5
	snes	.req	r6
	mov	result,	#0
	ldr	r0,	=SNESpad
	ldr	snes,	[r0]	

	ldr	r1,	=player_m
	mov	r5,	r1
	ldr	r2,	[r1]
	ldr	r3,	[r1, #4]
shoot:
	tst	snes,	#0b100000000	// a button	
	bne	horz
	mov	r0,	r1
	ldrb	r1,	[r1, #OBJ_DIR]
	bl	FireBullet
	mov	result,	#1
	b	done
horz:
	tst	snes,	#0b1000000	// left
	moveq	r0,	pAddr	// arg1 = object
	moveq	r1,	#8	// arg2 = direction
	bleq	MoveObject	// returns 1 if valid move
	cmp	r0,	#1
	moveq	result,	#1
	beq	done
	tst	snes,	#0b10000000	// right
	moveq	r0,	pAddr
	moveq	r1,	#2
	bleq	MoveObject	// returns 1 if valid move
	cmp	r0,	#1
	moveq	result,	#1
	beq	done
vert:
	tst	snes,	#0b10000	// up
	moveq	r0,	pAddr
	moveq	r1,	#1
	bleq	MoveObject// returns 1 if valid move
	cmp	r0,	#1
	moveq	result,	#1
	beq	done
	tst	snes,	#0b100000	// down
	moveq	r0,	pAddr
	moveq	r1,	#4
	bleq	MoveObject// returns 1 if valid move
	cmp	r0,	#1
	moveq	result,	#1
	beq	done
done:
	mov	r0,	result
	.unreq	result
	.unreq	pAddr
	.unreq	snes
	pop	{r4-r6,pc}

.section .data

