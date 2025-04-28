// kernel.c
void kmain(void) {
    char *vga = (char *)0xA0000;
    for (int i = 0; i < 320 * 200; i++) {
        vga[i] = 0x01; // Blue color
    }
    while (1);
}