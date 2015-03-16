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
	str	r0,	[r1]		// save FrameBufferPointer for later
	bl      Tests		// run game tests
	bl      GameMain	// branch to the Game 

haltLoop$:
	b		haltLoop$

.section .data

