; src/asm/boot.asm
section .multiboot_header ; nazwa sekcji, do użycia w link.ld
align 8 ; wyrównanie pamięci - upewniamy się, że następne dane zaczną się od
; adresów podzielnych przez 8 (dla GRUB-a)

MB2_MAGIC equ 0xE85250D6 ; identyfikator standardu multiboot2
MB2_ARCH equ 0 ; mówimy GRUB-owi - zanim oddasz kontrolę, przełącz CPU w 
; tryb 32-bitowy, architektura i386
MB2_LENGTH equ multiboot_header_end - multiboot_header_start
; Liczymy długość nagłówka

; Nazwa dla adresu pamięci, w którym jesteśmy
multiboot_header_start:
	; dd - define double word - definiujemy te dane jako dane w pliku binarnym
	dd MB2_MAGIC
	dd MB2_ARCH
	dd MB2_LENGTH
	; Według standardu magic + arch + length + checksum = 0
	; tutaj stosujemy trick aby obliczyć checksum
	dd 0x100000000 - (MB2_MAGIC + MB2_ARCH + MB2_LENGTH) ; Checksum
	; dodatkowe dane do GRUB-a - tag kończący
	dw 0 ; type
	dw 0 ; flags
	dd 8 ; size
; Znacznik końca - wymagany do obliczenia MB2_LENGTH
multiboot_header_end:

section .bss
align 16
stack_bottom:
    resb 16384
stack_top:

; Znacznik początka instrukcji procesora
section .text
; Dzięki temu linker zobaczy etykietę start i będziemy mogli jej używać
global _start
extern kmain

; adres pod który skoczy procesor
_start:
    mov esp, stack_top
    ; Jesteśmy w 32-bit Protected Mode - możemy operować bezpośrednio na pamięci
    ; adres [0xb8000] to fizyczny adres VGA text buffer - co tu wpiszemy pojawi
    ; się na ekranie, word - 16 bitowe słowo (2 bajty)
    ; mov word [0xb8000], 0x0248 ; 0x02 - kod koloru - zielona litera na czarnym tle
    ; 0x48 - kod ASCII litery 'H'
    ; mov word [0xb8002], 0x0269 ; analogicznie ox69 - kod ascii litery 'i'

    call kmain

    ; każemy procesorowi zasnąć do następnego przerwania, ale przerwania nie 
    ; działają, więc CPU zaśnie do restartu systemu
    .hang:
        hlt
        ; Jeżeli CPU się obudzi ma ponownie wypisać 'Hi' - skoczy do sekcji _start
        jmp .hang