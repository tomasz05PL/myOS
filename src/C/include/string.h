#ifndef STRING_H
#define STRING_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

size_t strlen(const char* str);

void reverse(char* str);

void itoa(int value, char* buffer, int base);

#endif