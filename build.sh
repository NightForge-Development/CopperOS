#!/bin/bash

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