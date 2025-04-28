# To build:
---
```bash
nasm -f bin bootloader.asm -o bootloader.bin
x86_64-elf-gcc -ffreestanding -mno-red-zone -nostdlib -m64 -c kernel.c -o kernel.o
ld -r -b binary logo-128.bmp -o logo.o
x86_64-elf-ld -Ttext=0x1000 --oformat binary kernel.o logo.o -o kernel.bin

cat bootloader.bin kernel.bin > os-image.bin

qemu-system-x86_64 -drive format=raw,file=os-image.bin -vga std
```
