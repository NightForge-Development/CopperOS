#include <stdint.h>

#define WIDTH  1024
#define HEIGHT 768

// Extern from bootloader
extern uint64_t framebuffer_addr;
__attribute__((weak)) uint64_t framebuffer_addr = 0;  // Provide default definition for linker

// Extern from BMP
extern uint8_t _binary_logo_128_bmp_start;
extern uint8_t _binary_logo_128_bmp_end;
extern uint8_t _binary_logo_128_bmp_size;

typedef struct {
    uint16_t type;              // Magic identifier: 0x4d42 ("BM")
    uint32_t size;              // BMP file size
    uint16_t reserved1;
    uint16_t reserved2;
    uint32_t offset;            // Offset to image data
    uint32_t dib_header_size;
    int32_t  width;
    int32_t  height;
    uint16_t planes;
    uint16_t bits_per_pixel;
    uint32_t compression;
    uint32_t image_size;
    int32_t  x_pixels_per_meter;
    int32_t  y_pixels_per_meter;
    uint32_t colors_used;
    uint32_t important_colors;
} __attribute__((packed)) BMPHeader;

void draw_pixel(uint32_t* fb, uint32_t x, uint32_t y, uint32_t color) {
    fb[y * WIDTH + x] = color;
}

// We'll embed the BMP directly into memory
extern uint8_t _binary_logo_128_bmp_start;
extern uint8_t _binary_logo_128_bmp_end;

void kernel_main(void) {
    uint32_t* fb = (uint32_t*)(uintptr_t)framebuffer_addr;

    // Clear screen
    for (uint32_t y = 0; y < HEIGHT; ++y)
        for (uint32_t x = 0; x < WIDTH; ++x)
            draw_pixel(fb, x, y, 0x00000000);

    // Load BMP
    BMPHeader* bmp = (BMPHeader*)&_binary_logo_128_bmp_start;
    uint8_t* pixel_data = &_binary_logo_128_bmp_start + bmp->offset;

    for (uint32_t y = 0; y < bmp->height; ++y) {
        for (uint32_t x = 0; x < bmp->width; ++x) {
            uint32_t idx = (x * 3) + (y * bmp->width * 3);
            uint8_t blue = pixel_data[idx];
            uint8_t green = pixel_data[idx + 1];
            uint8_t red = pixel_data[idx + 2];

            uint32_t color = (red << 16) | (green << 8) | blue;

            // BMP is stored upside down!
            draw_pixel(fb, x, bmp->height - y - 1, color);
        }
    }

    while (1) {
        __asm__ volatile ("hlt");
    }
}
