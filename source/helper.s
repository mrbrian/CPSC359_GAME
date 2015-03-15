.include "constants.s"
.globl SetGPIOFunc

/* r0 = new function, r1 = pin # */
SetGPIOFunc:
	ldr	r2, 	=GPIOFSEL0 	// r2 = base addr

setGPIOloop$:				
	cmp	r1,	#9		// pin # < 9
	subhi	r1,	#10		// pin# - 10
	addhi	r2,	#4		// offset + 4
	bhi	setGPIOloop$
					// r1 = pin# mod 10
	add	r1,	r1,	lsl #1	// r1 *= 3
	lsl	r0,	r1		// r1=starting bit #
					// r0=function
	mov	r3,	#7		// bit clear pattern
	lsl	r3,	r1		// shift r3 by starting bit

	ldr	r1,	[r2]		//load GPFSEL register
	bic	r1,	r3		//clear the bits
	orr	r0,	r1		// orr it.
	str	r0,	[r2]		//store func back into GPFSEL 
	bx	lr

.globl GetGPIOFunc

/* r0 = pin # */
GetGPIOFunc:
	ldr	r2, 	=GPIOFSEL0 	// r2 = base addr

getGPIOloop$:				
	cmp	r0,	#9		// pin # < 9
	subhi	r0,	#10		// pin# - 10
	addhi	r2,	#4		// offset + 4
	bhi	getGPIOloop$
					// r0 = pin# mod 10
	add	r0,	r0,	lsl #1	// r0 *= 3
	lsl	r1,	r0		// r0=starting bit #
					// r1=function
	mov	r3,	#7		// bit clear pattern

	ldr	r1,	[r2]		//load GPFSEL register
	lsr	r1,	r0		// shift r3 by starting bit
	and	r1,	r1,	r3
	bx	lr

.globl WriteGPIO

/* WriteGPIOFunc(line#, value) 
/* r0 = pin#, r1 = value to write */
WriteGPIO:	
	push	{r4, r5}
	ldr	r2,	=GPIOFSEL0
	mov	r4,	#40
	mov	r5,	#28

	cmp	r0,	#32
	addhi	r4,	#4
	addhi	r5,	#4
	subhi	r0,	#32

	mov	r3,	#1
	lsl	r3,	r0
	teq	r1,	#0
	streq	r3,	[r2,	r4]
	strne	r3,	[r2,	r5]
	pop	{r4, r5}
	bx	lr

.globl ReadGPIO

/* ReadGPIOFunc(line#, value) 
/* r0 = pin#  r1 = value */
ReadGPIO:	
	ldr	r2,	=GPIOFSEL0	// base GPIO reg
	ldr	r1,	[r2,	#52]	//GPLEV0
	mov	r3,	#1	
	lsl	r3,	r0		// align pin3 bit
	and	r1,	r3		// mask everything else
	teq	r1,	#0
	moveq	r0,	#0		// return 0
	movne	r0,	#1		// return 1
	bx	lr

.globl	Wait
/* r0 = micros */
Wait:
	ldr	r3,	=0x20003004	// address of CLO(ck)
	ldr	r1,	[r3]		// read CLO
	add	r1,	r0		// add r0 micros
waitLoop:
	ldr	r2,	[r3]
	cmp	r1,	r2		// stop when CLO = r1
	bhi waitLoop
	bx	lr

/* Converts a int value to a string */
.globl	IntToString
IntToString:
	push	{r4-r9}
	num	.req	r4
	origNum	.req	r5
	mod	.req	r6
	count	.req	r7
	digit	.req	r8
	modAddr	.req	r9

	ldr	modAddr,	=modValues_m
	mov	count,		#0
	mov	num,		r1
	mov	origNum,	r1
	ldr	mod,		[modAddr]
modOuterLoop:
	mov	digit,		#0
	cmp	mod,	#0
	beq	mod_done
modInnerLoop:
	cmp	num,	mod	// do num-mod until num < mod
	blt	modInnerDone	
	sub	num,	mod
	add	digit,		#1
	b	modInnerLoop
modInnerDone:
	add	r2,	digit,	#48
	strb	r2,	[r0]	// add character to output..
	add	r0,	#1
	mul	digit,		mod
	sub	origNum,	num	
	add	count,		#1
	add	modAddr,	#4
	ldr	mod,		[modAddr]
	b	modOuterLoop
mod_done:	
	pop	{r4-r9}
	bx	lr

/* returns a sortof random number from 0 to r0 */
.globl	Random
Random:
	push	{r4,r5}
	rtemp	.req	r5

	ldr	r4,	=random_m
	ldr	r4,	[r4]
	mul	rtemp,	r4,	r4

	ldr	r4,	=random_m
	and	r4,	#0xFF
	str	r5,	[r4]
rmod:
	cmp	rtemp,	r0
	blt	rmod_done
	sub	rtemp, 	r0
	b	rmod
rmod_done:
	mov	r0,	r5
	pop	{r4,r5}
	bx	lr

.section .data	
.globl	random_m
random_m:
	.int	RAND_SEED
modValues_m:
	.int	1000000000
	.int	100000000
	.int	10000000
	.int	1000000
	.int	100000
	.int	10000
	.int	1000
	.int	100
	.int	10
	.int	1
	.int	0

