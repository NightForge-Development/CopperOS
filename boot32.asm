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