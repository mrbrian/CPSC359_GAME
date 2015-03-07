.section .text

.equ	size,	32
.equ	step,	32

.globl	UpdatePlayer
UpdatePlayer:
	push	{lr}

	ldr	r0,	=SNESpad
	ldr	r0,	[r0]	

	ldr	r1,	=PlayerInfo
	ldr	r2,	[r1]
	ldr	r3,	[r1, #4]
shoot:
	tst	r0,	#0b100000000	// a button
	//shoot
	beq	done
horz:
	tst	r0,	#0b1000000	// left
	subeq	r2,	#step
	beq	done
	tst	r0,	#0b10000000	// right
	addeq	r2,	#step
	beq	done
vert:
	tst	r0,	#0b10000	// up
	subeq	r3,	#step	
	beq	done
	tst	r0,	#0b100000	// down
	addeq	r3,	#step
	beq	done
done:
	cmp	r2,	#0	// constrain x axis
	movlt	r2,	#0
	cmp	r2,	#992
	movge	r2,	#992
	cmp	r3,	#0	// constrain y axis
	movlt	r3,	#0
	cmp	r3,	#736
	movge	r3,	#736
	str	r2,	[r1]
	str	r3,	[r1, #4]

	pop	{pc}

.globl	DrawPlayer
DrawPlayer:
	push	{lr}	

	mov	r0,	#32
	ldr	r3,	=PlayerInfo
	ldr	r1,	[r3]
	ldr	r2,	[r3, #4]
	ldr	r3,	=0xF800
	bl	DrawEmptySquare

	pop	{pc}	

.globl	ErasePlayer
ErasePlayer:
	push	{lr}	

	mov	r0,	#32
	ldr	r3,	=PlayerInfo
	ldr	r1,	[r3]
	ldr	r2,	[r3, #4]
	ldr	r3,	=0x0000
	bl	DrawEmptySquare

	pop	{pc}	

.section .data
.align	4
PlayerInfo:
	.int	0	// x
	.int	0	// y

