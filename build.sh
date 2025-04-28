#!/bin/bash

# Check for required tools
command -v nasm >/dev/null 2>&1 || { echo "Error: nasm is required"; exit 1; }
command -v x86_64-elf-gcc >/dev/null 2>&1 || { echo "Error: x86_64-elf-gcc is required"; exit 1; }
command -v x86_64-elf-ld >/dev/null 2>&1 || { echo "Error: x86_64-elf-ld is required"; exit 1; }
command -v qemu-system-x86_64 >/dev/null 2>&1 || { echo "Error: qemu-system-x86_64 is required"; exit 1; }
command -v convert >/dev/null 2>&1 || { echo "Error: ImageMagick (convert) is required"; exit 1; }

# Create a sample 320x200 BMP image if not provided
if [ ! -f image.bmp ]; then
    convert -size 320x200 xc:white -fill blue -draw "rectangle 50,50,270,150" image.bmp
fi
convert image.bmp -depth 8 -colors 256 rgb:image.raw

# Assemble bootloader stages
nasm -f bin boot.asm -o boot.bin
nasm -f bin boot32.asm -o boot32.bin
nasm -f bin boot64.asm -o boot64.bin
nasm -f bin second_stage.asm -o second_stage.bin

# Compile and link kernel
x86_64-elf-gcc -ffreestanding -mcmodel=large -mno-red-zone -c kernel.c -o kernel.o
x86_64-elf-ld -T linker.ld kernel.o -o kernel.bin

# Combine into disk image
cat boot.bin second_stage.bin boot32.bin boot64.bin kernel.bin > os_image.bin

# Test with QEMU
qemu-system-x86_64 -fda os_image.bin