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

print_num:
	push %bp
	mov %sp, %bp

	mov 4(%bp), %ax
	or %ax, %ax
	jz print_num_done

	push %ax
	call _print_num
	jmp print_num_end

	print_num_done:
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
	jz _print_num_done
	mov $0, %dx
	mov $10, %bx
	div %bx

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

	_print_num_done:
	mov %bp, %sp
	pop %bp
	ret

print_num_hex:
	push %bp
	mov %sp, %bp

	mov 4(%bp), %eax
	or %eax, %eax
	jz print_num_hex_done

	push %eax
	call _print_num_hex
	jmp print_num_hex_end

	print_num_hex_done:
	add $48, %al
	push %ax
	call putch

	print_num_hex_end:
	mov %bp, %sp
	pop %bp
	ret

_print_num_hex:
	push %bp
	mov %sp, %bp

	mov 4(%bp), %eax
	or %eax, %eax
	jz _print_num_hex_done
	mov $0, %edx	
	mov $16, %ebx
	div %ebx

	/* Save the environment */
	push %bp
	push %edx
	push %eax
	call _print_num_hex
	mov %sp, %bp
	mov (%bp), %eax
	mov 4(%bp), %edx
	mov 8(%bp), %bp

	mov %dl, %al
	cmp $10, %al
	jge ge_ten
	add $48, %al
	jmp __print
	ge_ten:
		add $55, %al
	__print:
	push %ax
	call putch

	_print_num_hex_done:
	mov %bp, %sp
	pop %bp
	ret

_0X:
	.asciz "0X"

putch:
	push %bp
	mov %sp, %bp

	mov 4(%bp), %ax
	mov $0xE, %ah
	int $0x10

	mov %bp, %sp
	pop %bp
	ret
