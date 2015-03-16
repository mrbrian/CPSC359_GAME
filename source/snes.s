/*
 * snes.s
 * Author: All taken from Tutorial Example 10 - tut10-support.s
 *	except for ReadSNES function
*/

.include "constants.s"
.section .text

/* Initialize the SNES Controller GPIO Pins
 *	LAT (GPIO 9) - Output
 *	CLK (GPIO 11) - Output
 *	DAT (GPIO 10) - Input
 */
.globl InitSNES
InitSNES:
	// GPIO 9 (LAT) is on GPIOFSEL0
	ldr		r0, =GPIOFSEL0
	ldr		r1, [r0]
	
	// clear bits 27-29 and set them to 001 (Output)
	bic		r1, #0x38000000
	orr		r1, #0x08000000

	// write back to GPIOFSEL0
	str		r1, [r0]

	// GPIO 10 & 10 are on GPIOFSEL1
	ldr		r0, =GPIOFSEL1
	ldr		r1, [r0]

	// clear bits 0-2 (GPIO 10) and 3-5 (GPIO 11), set 0-2 to 000 (Input) and 3-5 to 001 (Output)
	bic		r1, #0x0000003F
	orr		r1, #0x00000008

	// write back to GPIOFSEL1
	str		r1, [r0]

	// return
	bx		lr


/* Initialize ACT LED (GPIO 16) line to Output
 */
.globl InitLED
InitLED:
	ldr		r0, =GPIOFSEL1
	ldr		r1, [r0]			

	bic		r1, #0x001C0000
	orr		r1, #0x00040000

	str		r1, [r0]

	bx		lr

/* Set the Latch (GPIO 9) line level
 *	r0 - 0 (clear) or != 0 (set)
 */
.globl SetLATLevel
SetLATLevel:
	tst		r0, #1
	ldreq	r0, =GPIOCLR0
	ldrne	r0, =GPIOSET0

	ldr		r1, =0x00000200
	str		r1, [r0]

	bx		lr

/* Set the LED (GPIO 16) line level
 *	r0 - 0 (clear) or != 0 (set)
 */
.globl SetLEDLevel
SetLEDLevel:
	tst		r0, #1
	ldreq	r0, =GPIOCLR0
	ldrne	r0, =GPIOSET0

	ldr		r1, =0x00010000
	str		r1, [r0]

	bx		lr

.globl	ReadSNES
/* Read data from SNES and return it/save to memory
 *	
 * Returns:
 *	r0 - SNES button data
 */
ReadSNES:
	push	{r4, r5, lr}

	buttons	.req	r4
	mov	buttons,	#0	// intialize buttons to zero

	mov	r0,	#CLOCK	
	mov	r1,	#1
	bl	WriteGPIO	// write 1 to Clock 

	mov	r0,	#LATCH	
	mov	r1,	#1
	bl	WriteGPIO	// write 1 to Latch 

	mov	r0,	#12	// wait 12 micros
	bl	Wait

	mov	r0,	#LATCH	
	mov	r1,	#0
	bl	WriteGPIO	// write 0 to Latch 

	mov	r5,	#0	// i=0
pulseLoop:
	
	mov	r0,	#6	// wait 6 micros
	bl	Wait

	mov	r0,	#CLOCK	
	mov	r1,	#0
	bl	WriteGPIO	// write 0 to clock

	mov	r0,	#6
	bl	Wait	// wait 6 micros
		
	mov	r0,	#DATA	
	bl	ReadGPIO	// read bit from data
	
	lsl	r0,	r5
	orr	buttons,	r0	// store it into buttons
	
	mov	r0,	#CLOCK	
	mov	r1,	#1
	bl	WriteGPIO	// write 1 to clock

	add	r5,	#1	// i++

	cmp	r5,	#16	// if i < 16, loop again
	bLT	pulseLoop

done:
	mov	r0,	buttons		
	ldr	r1,	=SNESpad	
	str	buttons, [r1]	

	.unreq	buttons	
	pop	{r4, r5, pc}

.section .data
.align 4

.globl	SNESpad
SNESpad:
	.int	0xFFFFFFFF	// default all buttons off
