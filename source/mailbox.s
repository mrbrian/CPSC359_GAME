.section .text

.equ	REGADDR,0x2000B880	
.equ	PEEK,	0x10
.equ	READ,	0x00
.equ	WRITE,	0x20
.equ	STATUS,	0x18
.equ	SENDER,	0x14
.equ	CONFIG,	0x1C

.globl 	InitFrameBufferInt
InitFrameBufferInt:

	// send msg, mailbox 0, ch 1

	push	{r4, r5, r6}
	ldr	r4,	=FrameBufferInfo
	ldr	r6,	=REGADDR

	add	r4,	#0x40000000
	and	r0,	r4,	#0b1111

	cmp	r0,	#0
	movne	r0,	#0
	popne	{r4, r5, r6}
	bxne	lr	

	orr	r4,	#1

wait1$:	
	ldr	r3,	[r6, #0x18]
	tst     r3, 	#0x80000000             // test bit 31
	bne     wait1$      

	str	r4,	[r6, #0x20]

wait2$:	
	ldr	r4,	[r6, #0x18]
	teq	r4,	#0x40000000	
	bne	wait2$
		
testo$:
	ldr	r4,	[r6, #0x00]
	and	r5,	r4,	#15
	
	cmp	r5,	#1
	bne	wait2$

	ands	r4,	#0xFFFFFFF0
	movne	r0,	#0
	popne	{r4, r5, r6}
	bxne	lr	

	mov 	r0,	r5
	pop	{r4, r5, r6}
	bx	lr


