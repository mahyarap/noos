# Upon turning on the computer, the CPU starts working in the so-called
# 16-bit real mode.
.code16

# The address the bootloader is loaded into
.equ LOADOFF, 0x7C00

# The magic number must be placed at 511th byte of the 1st sector. However some
# BIOS' do not require this number for floppy disks.
.equ MAGICNUM, 0xAA55

.text
.globl _start
_start:
	# Initialize the segment registers
	cli
	ljmp $0x0, $next_instruct
	next_instruct:
		xor %ax, %ax
		mov %ax, %ds
		mov %ax, %es
		mov %ax, %fs
		mov %ax, %gs

		# Set up the stack
		mov %ax, %ss
		mov $LOADOFF, %sp
		sti

		# Print hello
		push $hello
		call puts

		# Print num_msg
		push $num_msg
		call puts

		push $130
		call print_num
		# ASCII code of +
		push $43
		call print_sym
		push $202
		call print_num
		# ASCII code of =
		push $61
		call print_sym
		# Do simple arithmetic
		push $130
		push $202
		call sum
		# Return value of sum
		push %ax
		call print_num

		ret

puts:
	# Prologue
	push %bp
	mov %sp, %bp

	mov 4(%bp), %si
	cld
	puts_loop:
		lodsb
		or %al, %al
		jz puts_done
		mov $0xE, %ah
		int $0x10
		jmp puts_loop
	puts_done:
		# Epilogue	
		mov %bp, %sp
		pop %bp
		ret

# NOTE: It has some limitations due to registers width
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
	mov $0xE, %ah
	int $0x10

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

	# Save the environment
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
	mov $0xE, %ah
	int $0x10

	_print_sum_done:
	mov %bp, %sp
	pop %bp
	ret

print_sym:
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
