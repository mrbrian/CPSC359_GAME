.include "constants.s"
.section .text

.equ	RECT_X,		-20
.equ	RECT_Y,		-16
.equ	RECT_CLR,	-12
.equ	RECT_W,		-8
.equ	RECT_H,		-4

.globl	DrawCenteredRectangle 
/* Draws a filled rectangle, centered about (cx, cy)
 * r0 = memory pointer to variables on the stack
 *	[r0, #-20] = x coord
 *	[r0, #-16] = y coord
 *	[r0, #-12] = color
 *	[r0, #-8] = width
 *	[r0, #-4] = height
 * Returns:
 * 	r0 = original r0 value
 */
DrawCenteredRectangle:
	push	{r4, lr}
		
	mPtr 	.req	r4

	mov	mPtr,	r0
	ldr	r0,	[mPtr, #RECT_X]	// x
	add	r0,	#16
	ldr	r1,	[mPtr, #RECT_W]	// width
	sub	r0,	r0,	r1, lsr #1
	str	r0,	[mPtr, #RECT_X]

	ldr	r0,	[mPtr, #RECT_Y]	// y
	add	r0,	#16
	ldr	r1,	[mPtr, #RECT_H]	// height
	sub	r0,	r0,	r1, lsr #1
	str	r0,	[mPtr, #RECT_Y]

	mov	r0,	mPtr
	bl	DrawFilledRectangle
	pop	{r4, pc}


.globl	DrawFilledRectangle 
/* Draws a filled rectangle
 *	r0 = memory pointer to variables on the stack
 *	[r0, #-20] = x coord
 *	[r0, #-16] = y coord
 *	[r0, #-12] = color
 *	[r0, #-8] = width
 *	[r0, #-4] = height
 * Returns:
 * 	r0 = original r0 value
 */
DrawFilledRectangle:
	push	{r4,r5, lr}
	size	.req	r0
	px	.req	r1
	py	.req	r2
	color	.req	r3	
	count	.req	r4
	memPtr	.req	r5
	
	mov	memPtr,	r0
	mov	count,	#0
fillLoop:
	ldr	size,	[memPtr, #RECT_H]	// height
	cmp	count,	size
	bge	filldone
	ldr	size,	[memPtr, #RECT_W]	// width
	ldr	px,	[memPtr, #RECT_X]	// x
	ldr	py,	[memPtr, #RECT_Y]	// y
	add	py,	count
	ldr	color,	[memPtr, #RECT_CLR]	// color	
	bl	DrawHorizontalLine
	add	count,	#1
	b	fillLoop
filldone:
	mov	r0,	memPtr
	.unreq	size
	.unreq	px
	.unreq	py
	.unreq	color
	.unreq	count
	.unreq	memPtr
	pop	{r4,r5,pc}	

.globl	DrawEmptyRectangle 
/* Draws an empty rectangle
 *	r0 = memory pointer to variables on the stack
 *	[r0, #-4] = x coord
 *	[r0, #-8] = y coord
 *	[r0, #-12] = color
 *	[r0, #-16] = width
 *	[r0, #-20] = height
 * Returns:
 * 	r0 = original r0 value
 */
DrawEmptyRectangle:
	push	{r4,lr}
	
	size	.req	r0
	px	.req	r1
	py	.req	r2
	color	.req	r3	
	memPtr	.req	r4

	mov	memPtr,	r0
	ldr	size,	[memPtr, #RECT_H]	// height
	ldr	px,	[memPtr, #RECT_X]	// x
	ldr	py,	[memPtr, #RECT_Y]	// y
	ldr	color,	[memPtr, #RECT_CLR]	// color
	bl	DrawVerticalLine
		
	ldr	size,	[memPtr, #RECT_W]	// width
	ldr	px,	[memPtr, #RECT_X]	// x
	ldr	py,	[memPtr, #RECT_Y]	// y
	ldr	color,	[memPtr, #RECT_CLR]	// color
	bl	DrawHorizontalLine

	ldr	size,	[memPtr, #RECT_W]	// width
	ldr	px,	[memPtr, #RECT_X]	// x
	add	px,	size		// x = initial x + width
	sub	px,	#1
	ldr	size,	[memPtr, #RECT_H]	// height
	ldr	py,	[memPtr, #RECT_Y]	// y
	ldr	color,	[memPtr, #RECT_CLR]	// color
	bl	DrawVerticalLine

	ldr	size,	[memPtr, #RECT_H]	// height
	ldr	py,	[memPtr, #RECT_Y]	// y
	add	py,	size		// y = initial y + height
	sub	py,	#1
	ldr	size,	[memPtr, #RECT_W]	// width
	ldr	px,	[memPtr, #RECT_X]	// x
	ldr	color,	[memPtr, #RECT_CLR]	// color
	bl	DrawHorizontalLine

	mov	r0,	memPtr
	.unreq	size
	.unreq	px
	.unreq	py
	.unreq	color
	.unreq	memPtr

	pop	{r4,pc}	

.globl	DrawHorizontalLine 
/* Draws a rightwards horizontal line from x,y of specified length
 *	r0 - line length
 *	r1 - starting x coord
 *	r2 - starting y coord
 *	r3 - color half word
 */
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
	
.globl	DrawVerticalLine 
/* Draws a downward vertical line from x,y of specified length
 *	r0 - line length
 *	r1 - starting x coord
 *	r2 - starting y coord
 *	r3 - color half word
 */
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
/* Fills the entire screen with BG_COLOR (defined in constants.s)
 */
ClearScreen:
/*
	push	{lr}
	mov	r0,	#0
	bl	DrawScene
	pop	{lr}
*/
	push	{r4-r6,lr}
	x	.req	r4
	y	.req	r5
	offset	.req	r6
	
	ldr	r3,	=BG_COLOR
	mov	y,	#0

	ldr	r0,	=FrameBufferPointer
	ldr	r0,	[r0]	
yLoop:
	//for(int y = 0; y < 768; y++)
	cmp	y,	#SCR_HEIGHT
	bge	yLoopDone
	mov	x,	#0
xLoop:
	//for(int x = 0; x < 1024; x++)	
	cmp	x,	#SCR_WIDTH
	bge	xLoopDone
	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	x, y, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour at framebuffer pointer + offset
	str	r3,		[r0, offset]

	add	x,	#2
	b	xLoop
xLoopDone:
	add	y,	#1	
	b	yLoop
yLoopDone:
	.unreq	offset
	.unreq	x
	.unreq	y
	pop		{r4-r6,pc}

.globl	DrawPixel16bpp
/* Draw Pixel to a 1024x768x16bpp frame buffer
 * Note: no bounds checking on the (X, Y) coordinate
 *	r0 - frame buffer pointer
 *	r1 - pixel X coord
 *	r2 - pixel Y coord
 *	r3 - colour (use low half-word)

Author: Taken from Tutorial 07 Example - main.s 
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

