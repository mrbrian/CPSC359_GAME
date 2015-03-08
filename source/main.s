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

	ldr	r1,	=FrameBufferPointer
	str	r0,	[r1]

	b       testGame

	bl	InitSNES
	mov	r4,	#100	
	mov	r5,	#200
	ldr	r6,	=0xFFFF
gameLoop$:
	bl	ReadSNES
	//bl	ClearScreen
drawLoop$:
	
	bl	UpdatePlayer

	ldr	r0,	=0x1000
	bl	Wait

	b	gameLoop$
haltLoop$:
	b		haltLoop$

.section .data

