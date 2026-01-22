; src/asm/gdt.asm

global gdt_flush

gdt_flush:
    mov eax, [esp + 4] 

    lgdt [eax]

    ; Teraz krytyczny moment: Przeładowanie segmentów.
    ; 0x10 to offset Twojego segmentu DANYCH (Indeks 2 * 8 bajtów = 16 = 0x10)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Teraz przeładowanie segmentu KODU (CS).
    ; Nie można zrobić 'mov cs, 0x08'. Trzeba zrobić daleki skok (far jump).
    ; 0x08 to offset Twojego segmentu KODU (Indeks 1 * 8 bajtów = 8 = 0x08)
    jmp 0x08:.flush     ; Skocz do etykiety .flush, zmieniając CS na 0x08

.flush:
    ret                 ; Wróć do kodu C (do init_gdt)