; second_stage.asm
; Loads a 320x200 image for the loading screen
[bits 16]
[org 0x7000]

start:
    mov ax, 0xA000
    mov es, ax
    xor di, di
    mov cx, 320*200
    rep movsb
    ret
