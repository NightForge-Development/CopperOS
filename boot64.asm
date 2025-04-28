; boot64.asm
; 64-bit stage for x86-64 bootloader
[bits 64]
[org 0x9000]

; Constants
KERNEL_OFFSET equ 0x10000

start_long_mode:
    ; Update segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, 0x7FFFF

    ; Jump to kernel
    mov rax, KERNEL_OFFSET
    call rax
    jmp $

; Reuse GDT from boot.asm
DATA_SEG equ 16