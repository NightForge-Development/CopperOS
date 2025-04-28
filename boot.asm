; boot.asm
; 16-bit Bootloader for x86-64 OS
[bits 16]
[org 0x7C00]

; Constants
SECOND_STAGE_OFFSET equ 0x7000  ; Second stage load address
BOOT32_OFFSET equ 0x8000        ; 32-bit stage load address
BOOT64_OFFSET equ 0x9000        ; 64-bit stage load address
KERNEL_OFFSET equ 0x10000       ; Kernel load address
BOOT_INFO equ 0x500             ; Boot info structure address
VGA_BUFFER equ 0xA0000          ; VGA memory

start:
    ; Initialize registers and stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Set VGA mode 13h (320x200, 256 colors)
    mov ah, 0x00
    mov al, 0x13
    int 0x10

    ; Draw placeholder loading screen (red square)
    mov ax, 0xA000
    mov es, ax
    mov di, 320*100 + 100
    mov cx, 50
    mov al, 0x04        ; Red color
.draw_loop:
    mov bx, cx
    mov cx, 50
    rep stosb
    mov cx, bx
    add di, 320 - 50
    loop .draw_loop

    ; Set up boot info structure
    mov di, BO큼

    mov eax, VGA_BUFFER
    mov [di], eax       ; Store VGA buffer address
    xor eax, eax
    mov [di + 4], eax   ; Reserved for future use

    ; Load second stage, boot32, boot64, and kernel
    mov ah, 0x02        ; BIOS read sector
    mov al, 32          ; Sectors to read
    mov ch, 0
    mov cl, 2           ; Start from sector 2
    mov dh, 0
    mov dl, 0x80        ; Boot drive
    mov bx, SECOND_STAGE_OFFSET
    mov es, bx
    xor bx, bx
    int 0x13
    jc .disk_error

    ; Call second stage to display full image
    call SECOND_STAGE_OFFSET

    ; Switch to protected mode
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

; GDT
gdt_start:
    dq 0x0              ; Null descriptor
    ; Code segment (32-bit)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00
    ; Data segment
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

; Data
disk_error db 'Disk error!', 0

; Boot sector signature
times 510-($-$$) db 0
dw 0xAA55