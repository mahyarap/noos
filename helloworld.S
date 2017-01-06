#include "noos.h"

/* 
 * Upon turning on the computer, the CPU starts working in the so-called
 * 16-bit real mode.
 */
.code16

.text
.globl _start
_start:
	/* Initialization */
	INIT()

	/* Print hello */
	push $hello
	call puts

	/* Print num_msg */
	push $num_msg
	call puts

	push $99
	call print_num
	/* ASCII code of + */
	push $43
	call putch
	push $88
	call print_num
	/* ASCII code of = */
	push $61
	call putch
	/* Do simple arithmetic */
	push $99
	push $88
	call sum
	/* Return value of sum */
	push %ax
	call print_num

	ret

#include "io.h"

sum:
	push %bp
	mov %sp, %bp

	mov 4(%bp), %ax
	mov 6(%bp), %bx
	add %bx, %ax

	mov %bp, %sp
	pop %bp
	ret

hello:
	.asciz "Hello World!\r\n"
num_msg:
	.asciz "Simple arithmetic: "

.fill 0x1FE - (. - _start), 1, 0
.word MAGICNUM 
