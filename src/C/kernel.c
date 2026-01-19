#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#define VGA_MEMORY 0xb8000

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

enum vga_color {
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE = 1,
	VGA_COLOR_GREEN = 2,
	VGA_COLOR_CYAN = 3,
	VGA_COLOR_RED = 4,
	VGA_COLOR_MAGENTA = 5,
	VGA_COLOR_BROWN = 6,
	VGA_COLOR_LIGHT_GREY = 7,
	VGA_COLOR_DARK_GREY = 8,
	VGA_COLOR_LIGHT_BLUE = 9,
	VGA_COLOR_LIGHT_GREEN = 10,
	VGA_COLOR_LIGHT_CYAN = 11,
	VGA_COLOR_LIGHT_RED = 12,
	VGA_COLOR_LIGHT_MAGENTA = 13,
	VGA_COLOR_LIGHT_BROWN = 14,
	VGA_COLOR_WHITE = 15,
};
static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) {
    return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
    return (uint16_t) uc | (uint16_t)color << 8;
}

size_t strlen(const char* str) {
    size_t len = 0;
    while(str[len]) {
        len++;
    }
    return len;
}

void reverse(char* str) {
    int i, j;
    char c;
    for(int i = 0, j = strlen(str) - 1; i < j; ++i, --j) {
        c = str[i];
        str[i] = str[j];
        str[j] = c;
    }
}

void itoa(int value, char* buffer, int base) {
    int i = 0;
    bool isNegative = false;

    if(value == 0) {
        buffer[i++] = '0';
        buffer[i] = '\0';
    }

    if(value < 0 && base == 10) {
        isNegative == true;
        value = -value;
    }

    while (value != 0) {
        int rem = value % base;
        buffer[i++] = (rem > 9) ? (rem - 10) + 'a' : rem + '0';
        value = value / base;
    }
  
    if (isNegative) {
        buffer[i++] = '-';
    }
  
    buffer[i] = '\0';
  
    reverse(buffer);
}

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
volatile uint16_t* terminal_buffer;

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

void kmain(void) {
    terminal_initialize();
    char buf[20];
    itoa(32, buf, 2);
    terminal_writestring(buf);
    terminal_writestring("\nHello\n");
}