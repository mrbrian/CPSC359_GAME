.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
    mov     sp, #0x8000
			
	bl		EnableJTAG

	bl		InitFrameBuffer

	// branch to the halt loop if there was an error initializing the framebuffer
	cmp		r0, #0
	beq		haltLoop$

	mov	r1,	#100	
	mov	r2,	#100
	ldr	r3,	=0xFFFF
	bl	DrawPixel16bpp  

	bl	InitSNES
inputLoop$:
	bl	ReadSNES
haltLoop$:
	b		haltLoop$

.section .data

