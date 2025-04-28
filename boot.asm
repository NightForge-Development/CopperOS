; boot.asm
; x86-64 Bootloader for a C-based OS with a graphical loading screen
[bits 16]
[org 0x7C00]

; Constants
KERNEL_OFFSET equ 0x10000   ; Kernel load address (1MB)
VGA_BUFFER equ 0xA0000      ; VGA memory for 320x200x256

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

    ; Draw a simple loading screen (red square)
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

    ; Load kernel
    mov ah, 0x02        ; BIOS read sector
    mov al, 16          ; Sectors to read
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Start from sector 2
    mov dh, 0           ; Head 0
    mov dl, 0x80        ; Boot drive
    mov bx, KERNEL_OFFSET & 0xFFFF
    mov es, bx
    xor bx, bx
    int 0x13
    jc .disk_error

    ; Disable interrupts and switch to protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:init_protected_mode

.disk_error:
    mov si, disk_error
    mov ah, 0x0E
.print:
    lodsb
    test al, al
    jz $
    int 0x10
    jmp .print

[bits 32]
init_protected_mode:
    ; Set up segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9FFFF

    ; Set up paging for long mode
    ; Identity map first 2MB
    mov edi, 0x1000     ; Page table base
    xor eax, eax
    mov ecx, 0x1000     ; Clear 4KB
    rep stosd

    ; PML4 (0x1000)
    mov edi, 0x1000
    mov dword [edi], 0x2003     ; Point to PDPT
    ; PDPT (0x2000)
    mov edi, 0x2000
    mov dword [edi], 0x3003     ; Point to PD
    ; PD (0x3000)
    mov edi, 0x3000
    mov dword [edi], 0x4003     ; Point to PT
    ; PT (0x4000): Map first 2MB
    mov edi, 0x4000
    mov eax, 0x3        ; Present, writable
    mov ecx, 512        ; 512 entries (2MB)
.map_page:
    mov [edi], eax
    add eax, 0x1000     ; Next 4KB page
    add edi, 8
    loop .map_page

    ; Enable PAE
    mov eax, cr4
    or eax, 0x20        ; Set PAE bit
    mov cr4, eax

    ; Set up page table
    mov eax, 0x1000
    mov cr3, eax

    ; Enable long mode
    mov ecx, 0xC0000080 ; EFER MSR
    rdmsr
    or eax, 0x100       ; Set LME bit
    wrmsr

    ; Enable paging
    mov eax, cr0
    or eax, 0x80000001  ; Paging + Protected mode
    mov cr0, eax

    ; Jump to long mode
    jmp CODE_SEG:init_long_mode

[bits 64]
init_long_mode:
    ; Update segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, 0x9FFFF

    ; Jump to kernel
    mov rax, KERNEL_OFFSET
    call rax
    jmp $

; GDT
gdt_start:
    ; Null descriptor
    dq 0x0
    ; Code segment (64-bit)
    dw 0xFFFF           ; Limit
    dw 0x0000           ; Base low
    db 0x00             ; Base middle
    db 0x9A             ; Access (present, ring 0, code)
    db 0xAF             ; Granularity, 64-bit
    db 0x00             ; Base high
    ; Data segment
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92             ; Access (present, ring 0, data)
    db 0xCF             ; Granularity
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