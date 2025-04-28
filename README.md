# To Build:
## 1. Install dependencies on Ubuntu/Debian:
###    `sudo apt-get install nasm gcc binutils qemu-system-x86_64 imagemagick gcc-x86-64-linux-gnu binutils-x86-64-linux-gnu`
###    Note: Ensure gcc and ld support x86-64 bare-metal compilation.
###    If issues arise, build x86_64-elf-gcc/ld: https://wiki.osdev.org/GCC_Cross-Compiler
## 1. Install dependencies on macOS:
###    Install Homebrew if not already installed
###    `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
###    Install required dependencies
###    `brew install nasm gcc binutils qemu imagemagick`
###    Note: Ensure gcc and ld support x86-64 bare-metal compilation.
###    If issues arise, consider installing a cross-compiler (e.g., x86_64-elf-gcc/ld): https://wiki.osdev.org/GCC_Cross-Compiler
## 2. Save this script as `build_bootloader.sh`.
## 3. Make executable: `chmod +x build_bootloader.sh`
## 4. Run: `./build_bootloader.sh`