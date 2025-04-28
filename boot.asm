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