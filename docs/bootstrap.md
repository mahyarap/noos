# Overall Structure of Bootstraps
A bootstrap is a flat binary program which is intended to load the kernel
image. It is placed in the first sector of a storage device (MBR) such as
floppy disks and hard drives. Flat binary is a pure machine code without
any extra information (e.g. headers, symbolic tables, relocations and so
on). To achieve a flat binary, after compiling the assembly code with GNU
Assembler (GAS), we pass the option --oformat binary to the linker.

A bootstrap program has two forms: One used in floppy disks, CD ROMs and so
on which must be 512 bytes in size and the other used in MBR of hard disks
that must be less than 446 bytes. 48 remaining bytes are for the Partition
Table. A partition table contains this information:

Offset | Size    | Description
------ | ------- | -------------------------------------
0x000  | 436-446 | MBR Bootstrap
0x1B4  | 10      | Optional disk ID
0x1BE  | 64      | MBR Partition Table with 4 entries
0x1BE  | 16      | 1st Partition Table entry
0x1CE  | 16      | 2nd Partition Table entry
0x1DE  | 16      | 3rd Partition Table entry
0x1EE  | 16      | 4th Partition Table entry
0x1FE  | 2       | (0x55, 0xAA) Signature (little endian)

Each partition table entry has following attributes:

Offset | Size    | Description
------ | ------- | ----------------------------------------------------------
0      | byte    | Boot indicator flag: 0 = no, 0x80 = active (bootable) 
1      | byte    | Starting head
-      | 6 bits  | Starting sector (bits 6-7 upper two for starting cylinder)
3      | 10 bits | Starting cylinder
4      | byte    | System ID
5      | byte    | Ending head
-      | 6 bits  | Ending sector (bits 6-7 upper two for starting cylinder)
7      | 10 bits | Ending cylinder
8      | long    | Relative sector (to start of partition also starting LBA)
12     | long    | Total sectors in the partition

The bootstrap task in case of hard disks is to find the active partition,
load the first sector of it and pass the control to the program stored in
it. The first sector of the active partition in turn has another bootstrap
program that loads the kernel image into the memory.

## Real Mode
When the PC is powered on, the CPU starts working in the real mode. In the
real mode, the CPU works in 16-bit mode and only 20 bits of the data bus is
available so that almost 1 MB of RAM is accessible. The method of
addressing in this mode is the Segment-Offset method. This method uses a
logical address in the form of Segment:Offset to address memory. 

    Physical Address = (Segment * 0x10) + Offset

Registers that are involved in addressing are CS and IP in the form of
CS:IP. As an example, assume that the physical address of the current
instruction is 0x07C00 (note the leading zero, the physical address has
five digits). It means that The value of CS is 0x0000 and IP is 0x07C0, so
the physical address obtained by the formula is: CS * 0x10 + IP = 0x07C00.

In general, every instruction which is related to branching, uses CS
implicitly. As an example, if the next instruction was "JMP LABEL" (near
jump), the physical address would be: (CS * 0x10) + (IP + LABEL).
Instructions such as MOV, use DS implicitly. 

## Programming the Bootstrap
We must tell the linker how to assign an address to a symbol. The
--Ttext=0x0000 option tells the linker the starting address for symbols is
0x0. To compile for 16-bit mode, we use .code16 directive.

NOTE: the .org directive does not have the same effect as ORG directive of
NASM so that it should not be used.

When the bootstrap binary is loaded into the physical address 0x07C00 by the
BIOS, first of all, it should set up the stack immediately. To achieve
this, SS:SP registers should be fixed at 0x0000:0x7C00. It does not
overwrite the text section because we relocate the bootstrap right after
that. We also set up the segment registers to point to 0x0000. So far, the
memory layout is as follows: (BS = BootStrap)

                          +----------------------------+ <-- 0xFFFFF (1 MB)
                          |                            |
                          |          Unusable          |
                          |                            |
                          |----------------------------| <-- 0x7FFFF
                          |                            |
                          |                            |
                          |         Free Memory        |
                          |                            |
                          |                            |
                          |----------------------------| <-- 0x07DFF
                          |          BOOTSTRAP         |
    (Load off) SP, IP --> |----------------------------| <-- 0x07C00
                          |                            |
                          |         Free Memory        |
                          |                            |
       (Relocated BS) --> |----------------------------| <-- 0x00500
                          |           Unusable         |
       CS, DS, ES, SS --> +----------------------------+ <-- 0x00000

The stack grows downward. By relocating the bootstrap, there will be room
for the second bootstrap which comes from the first sector of the active
partition.
