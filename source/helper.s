.include "constants.s"

.globl SetGPIOFunc
/* Sets the GPIO Function of line r1, to r0
 * r0 = new function
 * r1 = line # 
*/
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
/* Returns the GPIO Function of line r0
 * r0 = line #
 */
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
/* Writes a 0, or 1 to GPIO Line r0
 * r0 = line # 
 * r1 = value to write 
 */
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
/* Returns the data bit for GPIO Line r0
 * r0 = line #  
*/
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
/* r0 = micros 
Author: Taken from ARM 7 lecture slides
*/
Wait:
	ldr	r3,	=0x20003004	// address of CLO(ck)
	ldr	r1,	[r3]		// read CLO
	add	r1,	r0		// add r0 micros
waitLoop:
	ldr	r2,	[r3]
	cmp	r1,	r2		// stop when CLO = r1
	bhi waitLoop
	bx	lr

/* Converts an int value r1 to a string, storing it into the address r0
 * r0 = address of string 
 * r1 = int value 
*/
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
	cmp	mod,	#0	// start from 10^9's place and work down to 1's place
	beq	mod_done	// end loop after converting 1's place
modInnerLoop:
	cmp	num,	mod	// digit = count how many times we can subtract mod from num
	blt	modInnerDone	
	sub	num,	mod
	add	digit,		#1
	b	modInnerLoop
modInnerDone:
	add	r2,	digit,	#48	// add 48 to digit to get ascii value
	strb	r2,	[r0]	// save character to output string[count]
	add	r0,	#1
	mul	digit,		mod	// shift digit back to its place
	sub	origNum,	num	// and subtract it from the original number
	add	count,		#1	// increment counter
	add	modAddr,	#4	// getting address of the next mod value
	ldr	mod,		[modAddr]	// loading the next mod value (current mod/10)
	b	modOuterLoop
mod_done:	
	pop	{r4-r9}
	bx	lr

.globl	RandomDirection
/* Uses the clock to return a sortof random number 1,2,4, or 8
 * Returns:
 * 	r0 - returns 2 LSB of clock
*/
RandomDirection:
	push	{r4-r5,lr}
	ldr	r4,	=CLOCKADDR
	ldr	r4,	[r4]

	ldr	r5,	=0xFFFFFFFC
	bic	r1,	r4,	r5

	mov	r0,	#1
	lsl	r0,	r1
	
	pop	{r4-r5,pc}
	bx	lr

.section .data	
modValues_m:
	.int	1000000000	// all the mod values, easily retrievable in sequence
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

