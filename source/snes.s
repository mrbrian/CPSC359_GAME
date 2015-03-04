.globl	InitSNES

.equ	CLOCK,	11
.equ	DATA,	10
.equ	LATCH,	9

InitSNES:
	push	{r4, r5, lr}

	//InitSNESClock:	
	mov	r1,	#11
	mov	r0,	#1
	bl	SetGPIOFunc

	//SNESLatchOutput:
	mov	r1,	#9
	mov	r0,	#1
	bl	SetGPIOFunc

	//SNESDataInput:
	mov	r1,	#10
	mov	r0,	#0
	bl	SetGPIOFunc

	pop	{r4, r5, pc}


.globl	ReadSNES
ReadSNES:
	push	{r4, r5, lr}

	buttons	.req	r4
	mov	buttons,	#0	// r4 = buttons

	mov	r0,	#CLOCK	
	mov	r1,	#1
	bl	WriteGPIO	

	mov	r0,	#LATCH	
	mov	r1,	#1
	bl	WriteGPIO	

	mov	r0,	#12
	bl	Wait

	mov	r0,	#LATCH	
	mov	r1,	#0
	bl	WriteGPIO	

	mov	r5,	#0	// i=0
pulseLoop:
	
	mov	r0,	#6	// wait 6micros
	bl	Wait

	mov	r0,	#CLOCK	
	mov	r1,	#0
	bl	WriteGPIO	

	mov	r0,	#6
	bl	Wait
		
	mov	r0,	#DATA	
	bl	ReadGPIO
	
	lsl	r0,	r5
	orr	buttons,	r0
	
	mov	r0,	#CLOCK	
	mov	r1,	#1
	bl	WriteGPIO	

	add	r5,	#1	// i++

	cmp	r5,	#16	// if i < 16
	bLT	pulseLoop

	mov	r0,	buttons
	
	.unreq	buttons
done:
	pop	{r4, r5, pc}





