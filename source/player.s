.include "constants.s"
.section .text

.globl	UpdatePlayer
UpdatePlayer:
	push	{lr}

	ldr	r0,	=SNESpad
	ldr	r0,	[r0]	

	ldr	r1,	=player_m
	ldr	r2,	[r1]
	ldr	r3,	[r1, #4]
shoot:
	tst	r0,	#0b100000000	// a button	
	beq	done
horz:
	tst	r0,	#0b1000000	// left
	moveq	r0,	r1
	moveq	r1,	#8
	bleq	MoveObject
	beq	done
	tst	r0,	#0b10000000	// right
	moveq	r0,	r1
	moveq	r1,	#2
	bleq	MoveObject
	beq	done
vert:
	tst	r0,	#0b10000	// up
	moveq	r0,	r1
	moveq	r1,	#1
	bleq	MoveObject
	beq	done
	tst	r0,	#0b100000	// down
	moveq	r0,	r1
	moveq	r1,	#4
	bleq	MoveObject
	beq	done
done:
	pop	{pc}

.globl	DrawPlayer
DrawPlayer:
	push	{lr}	

	mov	r0,	#TILESIZE
	ldr	r3,	=player_m
	ldrb	r1,	[r3, #OBJ_X]
	lsl	r1,	#5
	ldrb	r2,	[r3, #OBJ_Y]
	lsl	r2,	#5
	ldrh	r3,	[r3, #OBJ_CLR]
	bl	DrawEmptySquare

	pop	{pc}	

.section .data

