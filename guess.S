#include "noos.h"

.code16

.text
.globl _start
_start:
	/* Initialization */
	INIT()
	/* Function prologue */
	push %bp
	mov %sp, %bp
	/* Make room for two variables:
	 * A random number
	 * User input
	 */
	sub $4, %sp

	/* Get the current time */
	xor %ax, %ax
	mov $0x02, %ah
	int $0x1A
	jc error
	/* Save the returned seconds */
	mov %dx, seconds
	/* The returned sedonds are in BCD foramt.
	 * We should convert them to binary.
	 */
	push $0xF000
	push seconds
	call bcd2bin
	mov $10, %bx
	mul %bl
	mov %ax, -2(%bp)

	push $0x0F00
	push seconds
	call bcd2bin
	add -2(%bp), %ax
	mov $10, %bx
	div %bl
	mov %ah, %al
	xor %ah, %ah
	mov %ax, -2(%bp)

	/* Reveal the number! */
	/* push -2(%bp) */
	/* call print_num */
	/* push $newline */
	/* call puts */

	guess_loop:
		push $guess_msg
		call puts
		/* Read a key (blocking) */
		xor %ax, %ax
		int $0x16
		xor %ah, %ah
		sub $48, %al
		mov %ax, -4(%bp)
		push %ax
		call print_num
		push $newline
		call puts

		/* Compare the input with the random number */
		mov -4(%bp), %ax
		cmp -2(%bp), %ax
		je guess_matched
		jl guess_too_low
		jg guess_too_high

		guess_matched:
			push $win_msg
			call puts
			jmp guess_loop
		guess_too_low:
			push $too_low_msg
			call puts
			jmp guess_loop
		guess_too_high:
			push $too_high_msg
			call puts
			jmp guess_loop
	ret

error:
	push $err_msg
	call puts
	error_inf_loop:
	jmp error_inf_loop

#include "io.h"

bcd2bin:
	push %bp
	mov %sp, %bp

	mov 4(%bp), %ax
	mov 6(%bp), %bx
	xor %cx, %cx
	loop_clock:
		cmp $0x000F, %bx
		je loop_clock_end
		shr $1, %bx
		inc %cx
		jmp loop_clock
	loop_clock_end:
	and 6(%bp), %ax
	shr %cl, %ax

	mov %bp, %sp
	pop %bp
	ret

seconds:
	.word 0
newline:
	.asciz "\r\n"
guess_msg:
	.asciz "Guess the number: "
win_msg:
	.asciz "You win!\r\n"
too_low_msg:
	.asciz "Too low!\r\n"
too_high_msg:
	.asciz "Too high!\r\n"
err_msg:
	.asciz "Something went wrong!\r\n"

.fill 0x1FE - (. - _start), 1, 0
.word MAGICNUM
