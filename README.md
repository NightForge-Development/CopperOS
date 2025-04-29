# Installing
## Download the latest release from GitHub Releases

# To Build:
## 1. Install dependencies on Ubuntu/Debian:
### Install Dependencies
`sudo apt-get install nasm gcc binutils qemu-system-x86_64 imagemagick gcc-x86-64-linux-gnu binutils-x86-64-linux-gnu`
## 1. Install dependencies on macOS:
### Install Homebrew if not already installed
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
###    Install required dependencies
`brew install nasm gcc binutils qemu imagemagick`
## 2. Make executable: `chmod +x build_bootloader.sh`
## 3. Run: `./build_bootloader.sh`
