.section    .init
.globl     _start

_start:
    b       main
    
.section .text

uhohLoop$:
	b		uhohLoop$
main:
    mov     sp, #0x8000
	
	bl	EnableJTAG
	bl	InitFrameBufferInt	// not working..
ready:	
	ldr	r0,	=FrameBufferInfo
	ldr	r0,	[r0, #36]
	cmp	r0,	#0
	beq	uhohLoop$

testo:	
	mov	r0,	#100
	mov	r1,	#100
	bl	DrawPixel

	bl	InitSNES
inputLoop$:
	bl	ReadSNES
	b	inputLoop$

haltLoop$:
	b		haltLoop$

.section .data

