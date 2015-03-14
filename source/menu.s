.include "constants.s"
.section .text

.globl	UpdateMenu
	bx	lr

.globl	DrawMenu
DrawMenu:
	push	{r4,r5,lr}
	ldr	r1,	=275
	ldr	r2,	=200
	ldr	r3,	=MENU_CLR1
	ldr	r4,	=450
	ldr	r5,	=300
	push	{r1-r5}
	bl	DrawFilledRectangle
	pop	{r1-r5}
	ldr	r3,	=MENU_CLR2
	push	{r1-r5}
	bl	DrawEmptyRectangle
	pop	{r1-r5}

	ldr	r0,	=mStr1
	ldr	r1,	=350
	ldr	r2,	=250
	bl	DrawString
	ldr	r0,	=mStr2
	ldr	r1,	=350
	ldr	r2,	=320
	bl	DrawString
	ldr	r0,	=mStr3
	ldr	r1,	=350
	ldr	r2,	=370
	bl	DrawString
	ldr	r0,	=mStr4
	ldr	r1,	=350
	ldr	r2,	=420
	bl	DrawString
	
	ldr	r1,	=330
	ldr	r2,	=340

	ldr	r3,	=MenuState
	ldr	r3,	[r3]
	sub	r3,	#1
	mov	r4,	#50
	mul	r3,	r4

	ldr	r3,	=MENU_CLR2
	ldr	r4,	=120
	ldr	r5,	=2
	push	{r1-r5}	
	bl	DrawFilledRectangle
	pop	{r1-r5}	
	pop	{r4,r5,pc}

UpdateMenu:
	bx	lr

.section .data
.globl	MenuState
MenuState:
	.int	0	// 0 = menu_off, 1 = resume, 2 = restart, 3 = quit

mStr1:	.asciz	"LE GAME MENU"
mStr2:	.asciz	"RESUME"
mStr3:	.asciz	"RESTART"
mStr4:	.asciz	"QUIT"

