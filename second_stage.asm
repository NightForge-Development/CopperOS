; second_stage.asm
[bits 16]
mov ax, 0xA000
mov es, ax
xor di, di
mov si, image_data
mov cx, 320*200
rep movsb
; Jump to kernel
cli
lgdt [gdt_descriptor] ; Reuse bootloader's GDT
mov eax, cr0
or eax, 0x1
mov cr0, eax
jmp 8:protected_mode

[bits 32]
protected_mode:
mov ax, 16
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax
mov esp, 0x9FFFF
jmp KERNEL_OFFSET

image_data:
    incbin "image.raw"