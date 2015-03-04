.section .text

.globl	DrawPixel

DrawPixel:
	px	.req	r0
	py	.req	r1
	addr	.req	r2

	ldr	addr,	=FrameBufferInfo
	ldr	addr,	[addr, #32]
	
	height	.req	r3
	ldr	height,	[addr, #4]
	sub	height,	#1
	cmp	py,	height
	movhi	pc,	lr

	.unreq	height
	width	.req	r3

	ldr	width,	[addr, #0]
	sub	width,	#1
	cmp	px,	width
	movhi	pc,	lr
	
	ldr	addr,	=FrameBufferInfo
	ldr	addr,	[addr, #32]
	
	add	width,	#1
	mla	px,	py,	width, px	// px = (py*width)+px	
	.unreq	width
	.unreq	py
	
	add	addr,	px,	lsl #1
	.unreq	px

	fore	.req	r3
	ldr	fore,	=0xFFFFFFFF
	ldrh	fore,	[fore]
	strh	fore,	[addr]
	
	.unreq	fore
	.unreq	addr

	mov	pc,	lr	

	bx	lr

.section .data
.align 12

.globl FrameBufferInfo
FrameBufferInfo:
	.int    1024    // 0 - Width
	.int    768     // 4 - Height
	.int    1024    // 8 - vWidth
	.int    768   	// 12 - vHeight
	.int    0       // 16 - GPU - Pitch
	.int    16      // 20 - Bit Depth
	.int    0       // 24 - X
	.int    0       // 28 - Y
	.int    0       // 32 - GPU - Pointer
	.int    0       // 36 - GPU - Size

