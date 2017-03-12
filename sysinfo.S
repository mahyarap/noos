#include "noos.h"

.code16

.text
.globl _start
_start:
	INIT()

	/* The device the bootloader was loaded from */
	push %bp
	mov %sp, %bp

	int $0x11
	push %ax

	push $dma
	call puts
	mov -2(%bp), %ax
	test $0x0008, %ax
	pushf
	call yesno

	push $coproc
	call puts
	mov -2(%bp), %ax
	test $0x0002, %ax
	pushf
	call yesno

	mov %bp, %sp
	pop %bp
	ret

yesno:
	push %bp
	mov %sp, %bp

	jz .L1
	push $yes
	call puts
	jmp .L2
.L1:
	push $no
	call puts
.L2:
	mov %bp, %sp
	pop %bp
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

ipl:
	.asciz "IPL diskette installed"
coproc:
	.asciz "math coprocessor"
ram:
	.asciz "old PC system board RAM < 256K"
point_device:
	.asciz "pointing device installed (PS/2)"
not_used:
	.asciz "not used on PS/2"
video_mode:
	.asciz "initial video mode"
diskette_drives:
	.asciz "# of diskette drives, less 1"
dma:
	.asciz "0 if DMA installed"
serial_ports:
	.asciz "number of serial ports"
game_adapter:
	.asciz "game adapter installed"
unused:
	.asciz "unused, internal modem (PS/2)"
printer_ports:
	.asciz "number of printer ports"

yes:
	.asciz ": Yes\r\n"
no:
	.asciz ": No\r\n"

newline:
.asciz "\r\n"

.fill 0x1FE - (. - _start), 1, 0
.word MAGICNUM 
