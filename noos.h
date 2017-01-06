/* The address the bootloader is loaded into */
#define LOADOFF 0x7C00

/* The magic number must be placed at 511th byte of the 1st sector. However
 * some BIOS' do not require this number for floppy disks.
 */
#define MAGICNUM 0xAA55

/*
 * Some BIOSes load the bootstrap program in 0x07C0:0x0000 instead of
 * 0x0000:0x7C00. Prevent this by doing a far jump to 0x0000:0x7C00. Also
 * initialize the segment registers and set the stack up.
 */
#define INIT() \
	cli; \
	ljmp $0x0, $next_instruct; \
	next_instruct:; \
		xor %ax, %ax; \
		mov %ax, %ds; \
		mov %ax, %es; \
		mov %ax, %fs; \
		mov %ax, %gs; \
		mov %ax, %ss; \
		mov $LOADOFF, %sp; \
		sti;
