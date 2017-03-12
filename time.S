#include "noos.h"

.code16

.text
.globl _start
_start:
	INIT()

	/* int 0x1A, AH=0x02
	 * on return:
	 * CF = 0 if successful
	 *    = 1 if error, RTC not operating
	 * CH = hours in BCD
	 * CL = minutes in BCD
	 * DH = seconds in BCD
	 * DL = 1 if daylight savings time option
	 */
	mov $0x02, %ah
	int $0x1A
	jc error
	mov %cx, save
	mov %dx, save+2

	push $msg
	call puts

	push $0xF000
	push save
	call clock
	push %ax
	call print_num

	push $0x0F00
	push save
	call clock
	push %ax
	call print_num

	push $58
	call putch

	push $0x00F0
	push save
	call clock
	push %ax
	call print_num

	push $0x000F
	push save
	call clock
	push %ax
	call print_num

	push $58
	call putch

	push $0xF000
	push save+2
	call clock
	push %ax
	call print_num

	push $0x0F00
	push save+2
	call clock
	push %ax
	call print_num

	ret

error:
	push $err_msg
	call puts
	hlt

clock:
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

#include "io.h"

save:
	.word 0, 0

msg:
	.asciz "Current time: "

err_msg:
	.asciz "Failed to get the current time\n"

.fill 0x1FE - (. - _start), 1, 0
.word MAGICNUM
