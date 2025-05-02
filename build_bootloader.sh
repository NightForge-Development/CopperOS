#!/bin/bash

# Check for required tools
command -v nasm >/dev/null 2>&1 || { echo "Error: nasm is required"; exit 1; }
command -v gcc >/dev/null 2>&1 || { echo "Error: gcc is required"; exit 1; }
command -v ld >/dev/null 2>&1 || { echo "Error: ld is required"; exit 1; }

# Create project directory
mkdir -p bootloader
cd bootloader

# Copy necessary files
cp ../boot.asm ./
cp ../boot32.asm ./
cp ../boot64.asm ./
cp ../second_stage.asm ./
cp ../linker.ld ./
cp ../kernel.c ./

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
