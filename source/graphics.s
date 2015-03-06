.section .text

.globl	ClearScreen
ClearScreen:
	push	{r4, r5, lr}
	x	.req	r4
	y	.req	r5

	mov	y,	#0

yLoop:
	//for(int y = 0; y < 768; y++)
	mov	x,	#0

xLoop:
	//for(int x = 0; x < 1024; x++)

	ldr	r0,	=FrameBufferPointer
	ldr	r0,	[r0]
	mov	r1,	x
	mov	r2,	y
	mov	r3,	#0000
	
	bl	DrawPixel16bpp

	add	x,	#1
	cmp	x,	#1024
	bLT	xLoop

	add	y,	#1
	cmp	y,	#768
	bLT	yLoop

	.unreq	x
	.unreq	y

	pop		{r4, r5, pc}


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
	strh	r3,		[r0, offset]

	pop		{r4}
	bx		lr

