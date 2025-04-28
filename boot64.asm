bits 64
org 0xA000

long_mode_start:
    ; We are in long mode
    ; Jump to kernel at 0x1000
    mov rax, 0x1000
    jmp rax


