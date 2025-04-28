; bootloader.asm (fragment)

; Before loading the kernel:
mov ax, 0x4F01          ; VBE function: Get Mode Info
mov cx, 0x118           ; VBE mode 0x118 (1024x768x32bpp)
mov di, vbe_mode_info   ; ES:DI = buffer
int 0x10                ; BIOS interrupt

; Now framebuffer address is stored at vbe_mode_info + offset 0x28

; Load the kernel (same as before)
; Enter 64-bit mode (same as before)

[BITS 64]
long_mode_start:
    ; Copy framebuffer address into a known memory place
    mov rax, [vbe_mode_info + 0x28]
    mov [framebuffer_addr], rax

    ; Set up stack
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov rsp, 0x80000

    ; Jump to kernel
    jmp 0x1000

; Data Section
vbe_mode_info:
    times 256 db 0     ; VBE mode info block (512 bytes)

framebuffer_addr:
    dq 0x0             ; 64-bit address for framebuffer
