#include "noos.h"

.code16

.text
.globl _start
_start:
	/* Initialization */
	INIT()
	xor %bx, %bx
	loop_mem:
	mov $0xE820, %ax
	mov $memory_map, %di
	mov $20, %cx
	mov $0x0534D4150, %edx
	int $0x15
	jc error
	/* Save %bx */
	mov %bx, BX

	push $base_addr
	call puts
	mov memory_map, %eax
	push %eax
	call print_num_hex
	push $newline
	call puts

	push $length
	call puts
	mov memory_map+8, %eax
	push %eax
	call print_num_hex
	push $newline
	call puts

	push $type
	call puts
	mov memory_map+16, %eax
	push %eax
	call print_num_hex
	push $newline
	call puts

	mov BX, %bx
	or %bx, %bx
	jnz loop_mem

	push %ax
	ret

error:
	mov %ah, %al
	xor %ah, %ah
	push %ax
	call print_num_hex
	push $error_msg
	call puts
	ret

#include "io.h"

newline:
	.asciz "\r\n"

BX:
	.word 0

error_msg:
	.asciz "Something went wrong!"

base_addr:
	.asciz "Base Address: 0X"

length:
	.asciz "Length: 0X"

type:
	.asciz "Type: "

memory_map:
	.long 0

.fill 0x1FE - (. - _start), 1, 0
.word MAGICNUM
