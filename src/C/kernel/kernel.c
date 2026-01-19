#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include "../include/vga.h"
#include "../include/string.h"

void kmain(void) {
    terminal_initialize();
    char buf[20];
    itoa(32, buf, 10);
    terminal_writestring(buf);
    terminal_writestring("\nHello\n");
}