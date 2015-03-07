.section .text

.equ scrWidth,	1024
.equ scrHeight,	768

.globl	DrawEmptyRectangle //(x,y,color,w,h) on stack
DrawEmptyRectangle:
	push	{lr}
	size	.req	r0
	px	.req	r1
	py	.req	r2
	color	.req	r3	
	ldr	r0,	[sp, #20]	// height

	bl	DrawVerticalLine
		
	ldr	size,	[sp, #16]	// width
	ldr	px,	[sp, #4]	// x
	ldr	py,	[sp, #8]	// y
	ldr	color,	[sp, #12]	// color
	bl	DrawHorizontalLine

	ldr	size,	[sp, #16]	// height
	ldr	px,	[sp, #4]	// x
	add	px,	size		// x = initial x + width
	ldr	size,	[sp, #20]	// height
	ldr	py,	[sp, #8]	// y
	ldr	color,	[sp, #12]	// color
	bl	DrawVerticalLine

	ldr	size,	[sp, #20]	// height
	ldr	py,	[sp, #8]	// y
	add	py,	size		// y = initial y + height
	ldr	size,	[sp, #16]	// width
	ldr	px,	[sp, #4]	// width
	ldr	color,	[sp, #12]	// color
	bl	DrawHorizontalLine


	.unreq	size
	.unreq	px
	.unreq	py
	.unreq	color

	pop	{pc}	

.globl	DrawEmptySquare //(size,x,y,color)
DrawEmptySquare:
	push	{r4-r7, lr}

	size	.req	r4
	px	.req	r5
	py	.req	r6
	color	.req	r7	

	mov	size,	r0
	mov	px,	r1
	mov	py,	r2
	mov	color,	r3

	bl	DrawHorizontalLine

	mov	r0,	size
	mov	r1,	px
	mov	r2,	py
	mov	r3,	color
	bl	DrawVerticalLine
	
	mov	r0,	size
	add	r1,	px,	size
	mov	r2,	py
	mov	r3,	color
	bl	DrawVerticalLine

	mov	r0,	size
	mov	r1,	px
	add	r2,	py,	size
	mov	r3,	color
	bl	DrawHorizontalLine

	.unreq	size
	.unreq	px
	.unreq	py
	.unreq	color

	pop	{r4-r7, pc}	

.globl	DrawHorizontalLine //(length,x,y,color)
DrawHorizontalLine:
	push	{r4-r7, lr}
	count	.req	r4
	px	.req	r5
	py	.req	r6	
	length	.req	r7
	mov	count,	#0
	mov	px,	r1
	mov	py,	r2
	mov	length,	r0
hlineLoop:
	//for(int x = 0; x < length; y++)
	cmp	count,	length
	beq	hlineDone

	ldr	r0,	=FrameBufferPointer
	ldr	r0,	[r0]
	add	r1,	px, 	count
	mov	r2,	py

	bl	DrawPixel16bpp	
	add	count,	#1
	b	hlineLoop
hlineDone:
	.unreq	count
	.unreq	px
	.unreq	py
	.unreq	length

	pop	{r4-r7, pc}
	
.globl	DrawVerticalLine //(length,x,y,color)
DrawVerticalLine:
	push	{r4-r7, lr}
	count	.req	r4
	px	.req	r5
	py	.req	r6	
	length	.req	r7
	mov	count,	#0
	mov	px,	r1
	mov	py,	r2
	mov	length,	r0
vlineLoop:
	//for(int x = 0; x < length; y++)
	cmp	count,	length
	beq	vlineDone

	ldr	r0,	=FrameBufferPointer
	ldr	r0,	[r0]
	mov	r1,	px
	add	r2,	py, 	count

	bl	DrawPixel16bpp	
	add	count,	#1
	b	vlineLoop

vlineDone:
	.unreq	count
	.unreq	px
	.unreq	py
	.unreq	length

	pop	{r4-r7, pc}
	

.globl	ClearScreen
ClearScreen:
	push	{r4,r5,lr}
	x	.req	r4
	y	.req	r5
	offset	.req	r6
	
	mov	y,	#0

	ldr	r0,	=FrameBufferPointer
	ldr	r0,	[r0]	
yLoop:
	//for(int y = 0; y < 768; y++)
	mov	x,	#0
xLoop:
	//for(int x = 0; x < 1024; x++)
	
	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	x, y, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset
	str	r3,		[r0, offset]

	add	x,	#2
	cmp	x,	#1024
	bLT	xLoop

	add	y,	#1
	cmp	y,	#768
	bLT	yLoop

	.unreq	offset
	.unreq	x
	.unreq	y

	pop		{r4,r5,pc}


.globl	DrawPixel16bpp
/* Draw Pixel to a 1024x768x16bpp frame buffer
 * Note: no bounds checking on the (X, Y) coordinate
 *	r0 - frame buffer pointer
 *	r1 - pixel X coord
 *	r2 - pixel Y coord
 *	r3 - colour (use low half-word)
 */
DrawPixel16bpp:
	push	{r4}

	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r1, r2, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset
	strh	r3,	[r0, offset]

	pop		{r4}
	bx		lr

