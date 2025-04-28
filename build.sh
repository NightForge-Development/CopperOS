#!/bin/bash

# Check for required tools
command -v nasm >/dev/null 2>&1 || { echo "Error: nasm is required"; exit 1; }
command -v gcc >/dev/null 2>&1 || { echo "Error: gcc is required"; exit 1; }
command -v ld >/dev/null 2>&1 || { echo "Error: ld is required"; exit 1; }
command -v qemu-system-x86_64 >/dev/null 2>&1 || { echo "Error: qemu-system-x86_64 is required"; exit 1; }

# Note: ImageMagick is optional for custom images
if ! command -v convert >/dev/null 2>&1; then
    echo "Warning: ImageMagick not found. Using placeholder image."
    # Create a simple placeholder image.raw (all white)
    dd if=/dev/zero of=image.raw bs=1 count=64000 2>/dev/null
fi

# Create a sample 320x200 BMP image if provided and ImageMagick is available
if [ -f image.bmp ] && command -v convert >/dev/null 2>&1; then
    convert image.bmp -depth 8 -colors 256 rgb:image.raw
fi

# Assemble bootloader stages
nasm -f bin boot.asm -o boot.bin
nasm -f bin boot32.asm -o boot32.bin
nasm -f bin boot64.asm -o boot64.bin
nasm -f bin second_stage.asm -o second_stage.bin

# Compile and link kernel
gcc -ffreestanding -mcmodel=large -mno-red-zone -m64 -c kernel.c -o kernel.o
ld -T linker.ld kernel.o -o kernel.bin

# Combine into disk image
cat boot.bin second_stage.bin boot32.bin boot64.bin kernel.bin > os_image.bin

# Test with QEMU
qemu-system-x86_64 -fda os_image.bin