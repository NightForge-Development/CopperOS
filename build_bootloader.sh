#!/bin/bash

# Check for required tools
command -v nasm >/dev/null 2>&1 || { echo "Error: nasm is required"; exit 1; }
command -v x86_64-elf-gcc >/dev/null 2>&1 || { echo "Error: x86_64-elf-gcc is required"; exit 1; }
command -v x86_64-elf-ld >/dev/null 2>&1 || { echo "Error: x86_64-elf-ld is required"; exit 1; }
command -v qemu-system-x86_64 >/dev/null 2>&1 || { echo "Error: qemu-system-x86_64 is required"; exit 1; }
command -v convert >/dev/null 2>&1 || { echo "Error: ImageMagick (convert) is required"; exit 1; }

# Create project directory
mkdir -p bootloader
cd bootloader

# File 1: boot.asm
cat > boot.asm << 'EOF'
; boot.asm
; 16-bit Bootloader for x86-64 OS
[bits 16]
[org 0x7C00]

; Constants
SECOND_STAGE_OFFSET equ 0x7000
BOOT32_OFFSET equ 0x8000
BOOT64_OFFSET equ 0x9000
KERNEL_OFFSET equ 0x10000
BOOT_INFO equ 0x500
VGA_BUFFER equ 0xA0000

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov ah, 0x00
    mov al, 0x13
    int 0x10

    mov ax, 0xA000
    mov es, ax
    mov di, 320*100 + 100
    mov cx, 50
    mov al, 0x04
.draw_loop:
    mov bx, cx
    mov cx, 50
    rep stosb
    mov cx, bx
    add di, 320 - 50
    loop .draw_loop

    mov di, BOOT_INFO
    mov eax, VGA_BUFFER
    mov [di], eax
    xor eax, eax
    mov [di + 4], eax

    mov ah, 0x02
    mov al, 32
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80
    mov bx, SECOND_STAGE_OFFSET
    mov es, bx
    xor bx, bx
    int 0x13
    jc .disk_error

    call SECOND_STAGE_OFFSET

    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:BOOT32_OFFSET

.disk_error:
    mov si, disk_error
    mov ah, 0x0E
.print:
    lodsb
    test al, al
    jz $
    int 0x10
    jmp .print

gdt_start:
    dq 0x0
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 8
DATA_SEG equ 16

disk_error db 'Disk error!', 0

times 510-($-$$) db 0
dw 0xAA55
EOF

# File 2: boot32.asm
cat > boot32.asm << 'EOF'
; boot32.asm
; 32-bit stage for x86-64 bootloader
[bits 32]
[org 0x8000]

BOOT64_OFFSET equ 0x9000

start_protected:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x7FFFF

    mov edi, 0x1000
    xor eax, eax
    mov ecx, 0x1000
    rep stosd

    mov edi, 0x1000
    mov dword [edi], 0x2003
    mov edi, 0x2000
    mov dword [edi], 0x3003
    mov edi, 0x3000
    mov dword [edi], 0x4003
    mov edi, 0x4000
    mov eax, 0x3
    mov ecx, 512
.map_page:
    mov [edi], eax
    add eax, 0x1000
    add edi, 8
    loop .map_page

    mov eax, cr4
    or eax, 0x20
    mov cr4, eax

    mov eax, 0x1000
    mov cr3, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 0x100
    wrmsr

    mov eax, cr0
    or eax, 0x80000001
    mov cr0, eax

    jmp CODE_SEG:BOOT64_OFFSET

CODE_SEG equ 8
DATA_SEG equ 16
EOF

# File 3: boot64.asm
cat > boot64.asm << 'EOF'
; boot64.asm
; 64-bit stage for x86-64 bootloader
[bits 64]
[org 0x9000]

KERNEL_OFFSET equ 0x10000
BOOT_INFO equ 0x500

start_long_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, 0x7FFFF

    mov rdi, BOOT_INFO

    mov rax, KERNEL_OFFSET
    call rax
    jmp $

DATA_SEG equ 16
EOF

# File 4: second_stage.asm
cat > second_stage.asm << 'EOF'
; second_stage.asm
; Loads a 320x200 image for the loading screen
[bits 16]
[org 0x7000]

start:
    mov ax, 0xA000
    mov es, ax
    xor di, di
    mov si, image_data
    mov cx, 320*200
    rep movsb
    ret

image_data:
    incbin "image.raw"
EOF

# File 5: kernel.c
cat > kernel.c << 'EOF'
// kernel.c
typedef struct {
    unsigned long vga_buffer;
    unsigned long reserved;
} BootInfo;

void kmain(BootInfo *boot_info) {
    char *vga = (char *)boot_info->vga_buffer;
    for (int i = 0; i < 320 * 200; i++) {
        vga[i] = 0x01;
    }
    while (1);
}
EOF

# File 6: linker.ld
cat > linker.ld << 'EOF'
OUTPUT_FORMAT(binary)
SECTIONS
{
    . = 0x10000;
    .text : { *(.text) }
    .data : { *(.data) }
    .bss : { *(.bss) }
}
EOF

# Create a sample 320x200 BMP image if not provided
if [ ! -f image.bmp ]; then
    convert -size 320x200 xc:white -fill blue -draw "rectangle 50,50,270,150" image.bmp
fi
convert image.bmp -depth 8 -colors 256 rgb:image.raw

# Assemble bootloader stages
nasm -f bin boot.asm -o boot.bin
nasm -f bin boot32.asm -o boot32.bin
nasm -f bin boot64.asm -o boot64.bin
nasm -f bin second_stage.asm -o second_stage.bin

# Compile and link kernel
x86_64-elf-gcc -ffreestanding -mcmodel=large -mno-red-zone -c kernel.c -o kernel.o
x86_64-elf-ld -T linker.ld kernel.o -o kernel.bin

# Combine into disk image
cat boot.bin second_stage.bin boot32.bin boot64.bin kernel.bin > os_image.bin

# Test with QEMU
qemu-system-x86_64 -fda os_image.bin