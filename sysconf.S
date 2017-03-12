#include "noos.h"

.code16

.text
.globl _start
_start:
	/* Initialization */
	INIT()
	call sysconf
	loop:
	jmp loop
	ret

error:
	push $error_msg
	call puts
	ret

sysconf:
	push %bp
	mov %sp, %bp

	xor %ax, %ax
	mov $0xC0, %ah
	int $0x15
	jc error

	sub $4, %sp
	mov %es, -2(%bp)
	mov %bx, -4(%bp)
	mov %es, %ax
	mov %ax, %ds
	push (%bx)
	push 2(%bx)
	push 4(%bx)
	push 6(%bx)
	push 8(%bx)
	xor %ax, %ax
	mov %ax, %ds

	mov -12(%bp), %ax
	/* mov %ah, %al */
	/* xor %ah, %ah */
	push %ax
	call print_num

	mov %bp, %sp
	pop %bp
	ret


#include "io.h"

error_msg:
	.asciz "READ!"

info:
	.word 1
	.byte 2
	.byte 3
	.byte 4
	.byte 5
	.long 6

.fill 0x1FE - (. - _start), 1, 0
.word MAGICNUM
