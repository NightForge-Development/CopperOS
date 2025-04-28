; boot.asm - 16-bit Real Mode Bootloader
bits 16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    lgdt [gdt_descriptor]

    ; Enter protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Jump to boot32 at 0x8000
    jmp 0x08:0x8000

; --- GDT ---
gdt_start:
    dq 0x0000000000000000     ; Null descriptor
    dq 0x00af9a000000ffff     ; Code segment (base=0, limit=4GB, execute/read)
    dq 0x00af92000000ffff     ; Data segment (base=0, limit=4GB, read/write)

gdt_descriptor:
    dw gdt_descriptor_end - gdt_start - 1
    dq gdt_start
gdt_descriptor_end:

; --- Padding ---
times 510-($-$$) db 0
dw 0xAA55

