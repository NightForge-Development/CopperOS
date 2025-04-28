# To build:
```bash
nasm -f bin boot.asm -o boot.bin

nasm -f bin boot32.asm -o boot32.bin

nasm -f bin boot64.asm -o boot64.bin

gcc -ffreestanding -mno-red-zone -nostdlib -m64 -c kernel.c -o kernel.o

ld -r -b binary logo-128.bmp -o logo.o

ld -Ttext=0x1000 -e kernel_main --oformat binary kernel.o logo.o -o kernel.bin

cat boot.bin boot32.bin boot64.bin kernel.bin > os-image.bin

qemu-system-x86_64 -drive format=raw,file=os-image.bin -vga std
```
