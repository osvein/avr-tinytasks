#include <avr/common.h>

.ifndef	zero_reg
#ifdef __AVR_TINY__
zero_reg = 17
#else
zero_reg = 1
#endif
.endif

/* stable C ABI - see header */
.global	task_terminate

/* unstable ABI */
.global	task_block_
.global	task_unblock_

.section	.data
	.byte	lo8(cpu_queue)
	.byte	hi8(cpu_queue)
cpu_queue:
	.byte	0
	.byte	0

.section	.text
task_block_:
	push	zero_reg	; potentially faster than ST with pre-decrement
	in	XL, _SFR_IO_ADDR(SPL)
	in	XH, _SFR_IO_ADDR(SPH)
	st	X, zero_reg
	movw	r24, X
	ld	XH, -Z
	ld	XL, -Z
	st	Z+, r24
	st	Z, r25
	st	X+, r24
	st	X, r25
task_terminate:
	lds	XL, cpu_queue
	lds	XH, cpu_queue+1
	ld	r24, X+
	sts	cpu_queue, r24
	ld	r24, X
	sts	cpu_queue+1, r24
	out _SFR_IO_ADDR(SPL), XL
	out	_SFR_IO_ADDR(SPH), XH
	ret

task_unblock_:
	ld	ZL, X+
	ld	ZH, X
	sbiw	Z, 0
	breq	0f
	ld	r24, Z+
	ld	r25, Z
	st	X, r24
	st	-X, r25
	st	Z, zero_reg
	st	-Z, zero_reg
	lds	XH, cpu_queue-1
	lds	XL, cpu_queue-2
	st	X+, ZL
	st	X, ZH
	sts	cpu_queue-1, ZH
	sts	cpu_queue-2, ZL
0:	ret
