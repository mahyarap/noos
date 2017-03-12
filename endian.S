#include "noos.h"

.code16

.text
.globl _start
_start:
	INIT()

	/* x86 machines are little endian so that it will print
	 * 0x0FFFEFFFF instead of 0x0FFFFFFFE
	 */
	xor %eax, %eax
	mov BX+2, %ax
	push %eax
	call print_num_hex
	mov BX+0, %ax
	push %eax
	call print_num_hex

	loop:
	jmp loop
	ret

#include "io.h"

BX:
	.long 0xFBFFFFFE
	/* 0xEFFF 0xFFBF */
	/* 0xFFFE 0xFBFF */

.fill 0x1FE - (. - _start), 1, 0
.word MAGICNUM
