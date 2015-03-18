.include "constants.s"
.section .text

.globl	UpdateMenu
/*	Updates the menu according to SNES pad input
 * Returns:
 * 	r0 = 1, if menu recieved input, else 0 
*/
UpdateMenu:
	push	{r4-r6,lr}

	pad	.req	r0	
	temp	.req	r1
	mstate	.req	r4
	msaddr	.req	r5
	result	.req	r6

	mov	result,	#0
	ldr	pad,	=SNESpad
	ldr	pad,	[pad]
	ldr	msaddr,	=MenuState	
	ldr	mstate,	[msaddr]

	tst	pad,	#0b1000	// is start pressed
	bne	startdone	// skip over menu toggle if start not pressed

	mov	result,	#1	
	cmp	mstate,	#0	// if menu is off
	bne	turnmenuoff
	mov	mstate,	#MENU_RESUME
	b	startdone
turnmenuoff:
	bl	ClearScreen
	bl	DrawScene
	mov	mstate,	#0
startdone:
	cmp	mstate,	#0	// is menu off
	beq	udone

	mov	result,	#MENU_RESUME
	cmp	mstate,	#MENU_RESUME	// if RESUME is selected, ignore up commands
	beq	udown
	tst	pad,	#0b10000	// up button mask
	subeq	mstate,	#1	
udown:
	cmp	mstate,	#MENU_QUIT	// if QUIT is selected, ignore down commands
	beq	abutton
	tst	pad,	#0b100000	// down button mask
	addeq	mstate,	#1
abutton:
	tst	pad,	#0b100000000	// a button mask
	bne	udone	// skip if a button not pressed
	cmp	mstate,	#MENU_RESUME	// if RESUME is selected, turn menu off
	beq	turnmenuoff
	cmp	mstate,	#MENU_RESTART	// if RESTART is selected, re-initalize game
	beq	mrestart	
	cmp	mstate,	#MENU_QUIT
	bne	udone
quitscreen:
	bl	ClearScreen		// if QUIT is selected, clear screen
	ldr	r0,	=byeStr
	ldr	r1,	=450
	ldr	r2,	=300
	ldr	r3,	=0xFFFF
	bl	DrawString		// and print a quit message
quitLoop:
	b	quitLoop
mrestart:
	mov	mstate,	#MENU_OFF	// turning off menu
	bl	ClearScreen	
	bl	InitGame		// re-initialize game
	bl	DrawScene	
udone:	
	str	mstate,	[msaddr]
	mov	r0,	result
	.unreq	pad
	.unreq	temp
	.unreq	result
	.unreq	mstate
	.unreq	msaddr
	pop	{r4-r6,pc}

.globl	DrawMenu
/*	Draws the menu + options to screen
*/
DrawMenu:
	ldr	r0,	=MenuState
	ldr	r0,	[r0]
	cmp	r0,	#0
	bxeq	lr		// if menu is off, then exit

	push	{r4,r5,lr}

	ldr	r1,	=275
	ldr	r2,	=200
	ldr	r3,	=MENU_CLR1
	ldr	r4,	=450
	ldr	r5,	=300
	mov	r0,	sp
	push	{r1-r5}
	bl	DrawFilledRectangle	// draw rectangle
	mov	sp,	r0
	ldr	r1,	=275
	ldr	r2,	=200
	ldr	r3,	=MENU_CLR2
	ldr	r4,	=450
	ldr	r5,	=300
	mov	r0,	sp
	push	{r1-r5}
	bl	DrawEmptyRectangle	// draw rectangle border
	mov	sp,	r0
	
	ldr	r0,	=mStr1
	ldr	r1,	=350
	ldr	r2,	=250
	bl	DrawString	// draw menu title
	ldr	r0,	=mStr2
	ldr	r1,	=350
	ldr	r2,	=320
	bl	DrawString	// draw option 1
	ldr	r0,	=mStr3
	ldr	r1,	=350
	ldr	r2,	=370
	bl	DrawString	// draw option 2
	ldr	r0,	=mStr4
	ldr	r1,	=350
	ldr	r2,	=420
	bl	DrawString	// draw option 3 
	
	ldr	r1,	=330
	ldr	r2,	=290

	ldr	r3,	=MenuState
	ldr	r3,	[r3]		// 1 to 3
	mov	r4,	#50
	mla	r2,	r3,	r4,	r2

	ldr	r3,	=MENU_CLR2
	ldr	r4,	=120
	ldr	r5,	=2
	mov	r0,	sp
	push	{r1-r5}	
	bl	DrawFilledRectangle	// draw underline the selected option
	mov	sp,	r0	
	pop	{r4,r5,pc}

.section .data
.globl	MenuState
MenuState:
	.int	0	// 0 = menu_off, 1 = resume, 2 = restart, 3 = quit

mStr1:	.asciz	"LE GAME MENU"	// menu strings
mStr2:	.asciz	"RESUME"
mStr3:	.asciz	"RESTART"
mStr4:	.asciz	"QUIT"
byeStr:	.asciz	"BYEBYE"

