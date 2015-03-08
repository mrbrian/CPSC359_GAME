.section .text

.globl	DrawString	// r0 address, r1=x, r2=y, r3=color
DrawString:
	push	{r4-r7, lr}
	char	.req	r4
	idx	.req	r5
	py	.req	r6
	addr	.req	r7

	mov	addr,	r0
	mov	py,	r2
	mov	idx,	#0

	ldrb	char,	[r7]
dsLoop:
	cmp	char,	#0
	beq	done

	mov	r0,	char
	add	r1,	#9
	mov	r2,	r6

	blne	DrawChar

	add	idx,	#1
	ldrb	char,	[addr, idx]
	b	dsLoop
done:
	.unreq	char
	.unreq	idx
	.unreq	py
	.unreq	addr
	pop	{r4-r7, pc}

.globl	DrawChar
/* Draw the character r0 to (0,0)
 */
DrawChar:
	push	{r4-r8, lr}

	chAdr	.req	r4
	px	.req	r5
	py	.req	r6
	row	.req	r7
	mask	.req	r8

	ldr		chAdr,	=font		// load the address of the font map
	add		chAdr,	r0, lsl #4	// char address = font base + (char * 16)

	mov		py,		r2	// init the Y coordinate (pixel coordinate)
	ldr	r0,	=FrameBufferPointer
	ldr	r0,	[r0]
charLoop$:
	mov		px,		r1	// init the X coordinate

	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1		// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$
	
	mov		r1,		px
	mov		r2,		py
	bl		DrawPixel16bpp		// draw pixel at (px, py)

noPixel$:
	add		px,		#1	// increment x coordinate by 1
	lsl		mask,	#1		// shift bitmask left by 1

	tst		mask,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$

	add		py,		#1	// increment y coordinate by 1
	sub		r1,	px,	#8
	tst		chAdr,	#0xF
	bne		charLoop$		// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop		{r4-r8, pc}

.section .data
.align 4

font:	
	.incbin	"font.bin"
