#include "../include/vga.h"

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;
static size_t terminal_row;
static size_t terminal_column;
static uint8_t terminal_color;
static volatile uint16_t* terminal_buffer;


static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) {
    return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
    return (uint16_t) uc | (uint16_t)color << 8;
}

void terminal_initialize(void) {
    terminal_row = terminal_column = 0;
    terminal_color = vga_entry_color(VGA_COLOR_GREEN, VGA_COLOR_BLACK);
    terminal_buffer = (volatile uint16_t*)VGA_MEMORY;

    const uint16_t clear_char = vga_entry(' ', terminal_color);

    for(size_t i = 0; i < VGA_WIDTH * VGA_HEIGHT; ++i) {
        terminal_buffer[i] = clear_char;
    }
}

void terminal_putchar(char c) {
    if(c == '\n') {
        terminal_row++;
        terminal_column = 0;
    }
    else {
        size_t index = terminal_row * VGA_WIDTH + terminal_column;
        const uint16_t char_to_put = vga_entry(c, terminal_color);

        terminal_buffer[index] = char_to_put;

        terminal_column++;
        if(terminal_column == VGA_WIDTH) {
            terminal_column = 0;
            terminal_row++;
        }
    }
    if(terminal_row == VGA_HEIGHT) {
        terminal_row = 0;
    }
}

void terminal_writestring(const char* str) {
    size_t len = strlen(str);
    for(size_t i = 0; i < len; ++i) {
        terminal_putchar(str[i]);
    }
}