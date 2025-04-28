; boot32.asm
; 32-bit stage for x86-64 bootloader
[bits 32]
[org 0x8000]

; Constants
BOOT64_OFFSET equ 0x9000

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
    ; PD (0x3000)
    mov edi, 0x3000
    mov dword [edi], 0x4003
    ; PT (0x4000): Map 2MB
    mov edi, 0x4000
    mov eax, 0x3        ; Present, writable
    mov ecx, 512
.map_page:
    mov [edi], eax
    add eax, 0x1000
    add edi, 8
    loop .map_page

    ; Enable PAE
    mov eax, cr4
    or eax, 0x20        ; PAE bit
    mov cr4, eax

    ; Set page table
    mov eax, 0x1000
    mov cr3, eax

    ; Enable long mode
    mov ecx, 0xC0000080 ; EFER MSR
    rdmsr
    or eax, 0x100       ; LME bit
    wrmsr

    ; Enable paging
    mov eax, cr0
    or eax, 0x80000001  ; Paging + protected mode
    mov cr0, eax

    ; Jump to 64-bit stage
    jmp CODE_SEG:BOOT64_OFFSET

; Reuse GDT from boot.asm
CODE_SEG equ 8
DATA_SEG equ 16