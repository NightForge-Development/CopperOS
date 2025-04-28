# To build:
```bash
nasm -f bin boot.asm -o boot.bin

x86_64-elf-gcc -ffreestanding -mcmodel=large -mno-red-zone -c kernel.c -o kernel.o
x86_64-elf-ld -Ttext 0x10000 --oformat binary kernel.o -o kernel.bin

cat boot.bin kernel.bin > os_image.bin

qemu-system-x86_64 -fda os_image.bin

convert image.bmp -depth 8 -colors 256 rgb:image.raw
```
