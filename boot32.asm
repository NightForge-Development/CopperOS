; boot32.asm - 32-bit Protected Mode Bootloader
bits 32
org 0x8000

protected_mode_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Setup long mode page tables
    mov eax, page_directory
    mov cr3, eax

    ; Enable long mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; Jump to boot64 at 0xA000
    jmp 0x08:0xA000

; Page tables
align 4096
page_directory:
    dq page_table + 0x03
    times 511 dq 0
page_table:
    times 512 dq 0x0000000000000003


