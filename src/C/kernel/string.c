#include "../include/string.h"

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
    for(i = 0, j = strlen(str) - 1; i < j; ++i, --j) {
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
        isNegative = true;
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