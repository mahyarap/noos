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

puts:
	/* Prologue */
	push %bp
	mov %sp, %bp

	mov 4(%bp), %si
	cld
	puts_loop:
		lodsb
		or %al, %al
		jz puts_done
		push %ax
		call putch
		jmp puts_loop
	puts_done:
		/* Epilogue */	
		mov %bp, %sp
		pop %bp
		ret

/* NOTE: It has some limitations due to registers width */
print_num:
	push %bp
	mov %sp, %bp

	mov 4(%bp), %ax
	or %ax, %ax
	jz print_sum_done

	push %ax
	call _print_num
	jmp print_num_end

	print_sum_done:
	add $48, %al
	push %ax
	call putch

	print_num_end:
	mov %bp, %sp
	pop %bp
	ret

_print_num:
	push %bp
	mov %sp, %bp

	mov 4(%bp), %ax
	or %ax, %ax
	jz _print_sum_done
	mov $0, %dx
	mov $10, %bx
	div %bx
	mov $0, %ah

	/* Save the environment */
	push %bp
	push %dx
	push %ax
	call _print_num
	mov %sp, %bp
	mov (%bp), %ax
	mov 2(%bp), %dx
	mov 4(%bp), %bp

	mov %dl, %al
	add $48, %al
	push %ax
	call putch

	_print_sum_done:
	mov %bp, %sp
	pop %bp
	ret

putch:
	push %bp
	mov %sp, %bp

	mov 4(%bp), %ax
	mov $0xE, %ah
	int $0x10

	mov %bp, %sp
	pop %bp
	ret

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
