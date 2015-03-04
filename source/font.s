.section .text

/* (char, x, y) 
WriteChar:
	push	{r4-r7, lr}

	ldr	r7, 	=font
	
	mov	r4,	#0	// i = 0
_cloop$:

	ldrb	r5,	[r7, r4]
	mov	r6,	#1
	mov	r3,	#0
_inloop$:
	teq	r5,	r6,	lsl #r3
	
	bl	drawPixel	

	add	r3,	#1
	cmp	r3,	#8
	bLT	_inloop$


	adds	r4,	#1	
	bLT	_cloop$		// i < 16

	pop	{r4-r7, pc}

drawPixel:
	bx	lr
*/
.section .data
.align 4

font:	
	.incbin	"font.bin"
