.section .text

.globl	InitGame
InitGame:
	

.globl	DrawScene
DrawScene:
	mov	r1,	#0
	mov	r2,	#0
	ldr	r3,	=0xFF0F
	ldr	r4,	=1023
	ldr	r5,	=767
	stmfd	sp!,	{r1-r5}
	bl	DrawEmptyRectangle
	ldmfd	sp!,	{r1-r5}

	bx	lr

.section .data

GameStrings:
	.asciz	"SCORE:"

.align 4
GameInfo:
	.int	0
	.skip	4
