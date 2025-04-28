# To Build:
## 1. Install dependencies on Ubuntu/Debian:
###    `sudo apt-get install nasm gcc binutils qemu-system-x86`
###    Note: Ensure gcc and ld support x86-64 bare-metal compilation.
###    If issues arise, consider installing a cross-compiler:
###    `sudo apt-get install gcc-x86-64-linux-gnu binutils-x86-64-linux-gnu`
###    Or build x86_64-elf-gcc/ld: https://wiki.osdev.org/GCC_Cross-Compiler
## 2. Install ImageMagick for custom images
###    `sudo apt-get install imagemagick`
## 3. Make executable: `chmod +x build_bootloader.sh`
## 4. Run: `./build_bootloader.sh`