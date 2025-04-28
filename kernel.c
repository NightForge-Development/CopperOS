// kernel.c
typedef struct {
    unsigned long vga_buffer; // VGA buffer address
    unsigned long reserved;   // For future use
} BootInfo;

void kmain(BootInfo *boot_info) {
    char *vga = (char *)boot_info->vga_buffer;
    for (int i = 0; i < 320 * 200; i++) {
        vga[i] = 0x01; // Blue color
    }
    while (1);
}