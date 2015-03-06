.section .text

.globl	UpdatePlayer
UpdatePlayer:
	ldr	r0,	=SNESpad
	ldr	r0,	[r0]
	
	tst	r0,	#0b100000
	addeq	r5,	#1

.globl	DrawPlayer


.section .data
.align	4
PlayerInfo:
	.int	0	// x
	.int	0	// y

