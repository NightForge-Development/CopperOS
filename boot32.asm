; boot32.asm
; 32-bit stage for x86-64 bootloader
[bits 32]
[org 0x8000]

; Constants
BOOT64_OFFSET equ 0x9000
KERNEL_OFFSET equ 0x10000

start_protected:
    ; Set up segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x7FFFF

    ; Set up paging (identity map first 2MB)
    mov edi, 0x1000     ; Page table base
    xor eax, eax
    mov ecx, 0x1000     ; Clear 4KB
    rep stosd

    ; PML4 (0x1000)
    mov edi, 0x1000
    mov dword [edi], 0x2003
    ; PDPT (0x2000)
    mov edi, 0x2000
    mov dword [edi], 0x3003
    ; PD (0x300