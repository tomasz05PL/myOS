ENTRY(_start)

SECTIONS
{
    /* Zaczynamy od 1MB */
    . = 1M;

    /* 1. Nagłówek Multiboot i kod (Read + Execute) */
    .text :
    {
        /* Najpierw nagłówek, żeby był na początku pliku */
        KEEP(*(.multiboot_header))
        *(.text)
    }

    /* 2. Dane tylko do odczytu (Read Only), np. stringi w C */
    .rodata :
    {
        *(.rodata)
    }

    /* 3. Dane zainicjalizowane (Read + Write), np. int a = 10; */
    .data :
    {
        *(.data)
    }

    /* 4. Dane niezainicjalizowane i STOS (Read + Write), np. int b; */
    .bss :
    {
        *(.bss)
    }
}