.section    .init
.globl     _start

_start:
    b       main

testStr:
.asciz	"TEST"
.align 	4
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

	bl	InitSNES
	mov	r4,	#100	
	mov	r5,	#200
	ldr	r6,	=0xFFFF
gameLoop$:
	bl	ReadSNES
	//bl	ClearScreen
drawLoop$:
	
	bl	UpdatePlayer

	ldr	r0,	=testStr
	mov	r1,	#0
	mov	r2,	#0
	ldr	r3,	=0xFFFF
	bl	DrawString

	ldr	r0,	=0x1000
	bl	Wait

	b	gameLoop$
haltLoop$:
	b		haltLoop$

.section .data

