# --- ZMIENNE NARZĘDZIOWE ---
ASM = nasm
CC = x86_64-elf-gcc
LD = x86_64-elf-ld
GRUB_MKRESCUE = i686-elf-grub-mkrescue
QEMU = qemu-system-x86_64

# --- ŚCIEŻKI ---
BUILD_DIR = build
SRC_DIR = src
# Dodajemy ścieżkę do nagłówków, żebyś mógł pisać #include <vga.h>
INCLUDE_DIR = src/include 

# --- FLAGI ---
ASM_FLAGS = -f elf32
# Dodajemy -I (Include) oraz flagi ostrzeżeń (ważne w cybersec!)
# -Wall -Wextra: Pokaż wszystkie ostrzeżenia (np. o nieużywanych zmiennych)
CC_FLAGS = -ffreestanding -m32 -c -I$(INCLUDE_DIR) -Wall -Wextra
LD_FLAGS = -m elf_i386 -n -T targets/link.ld

# --- AUTOMATYCZNE WYKRYWANIE PLIKÓW ---
# 1. Znajdź wszystkie pliki .c w katalogu src (i podkatalogach)
C_SOURCES := $(shell find $(SRC_DIR) -name '*.c')
# 2. Znajdź wszystkie pliki .asm
ASM_SOURCES := $(shell find $(SRC_DIR) -name '*.asm')

# 3. Zamień listę plików źródłowych na listę plików obiektowych (.o)
# Np. src/kernel/main.c -> build/kernel/main.o
C_OBJECTS := $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SOURCES))
ASM_OBJECTS := $(patsubst $(SRC_DIR)/%.asm, $(BUILD_DIR)/%.o, $(ASM_SOURCES))

# 4. Połącz obie listy w jedną
OBJECTS := $(ASM_OBJECTS) $(C_OBJECTS)

# --- REGUŁY ---

all: $(BUILD_DIR)/os.iso

run: $(BUILD_DIR)/os.iso
	$(QEMU) -cdrom $(BUILD_DIR)/os.iso

# Budowanie ISO
$(BUILD_DIR)/os.iso: $(BUILD_DIR)/kernel.bin
	mkdir -p $(BUILD_DIR)/isofiles/boot/grub
	cp $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/isofiles/boot/kernel.bin
	cp src/grub.cfg $(BUILD_DIR)/isofiles/boot/grub/grub.cfg
	$(GRUB_MKRESCUE) -o $(BUILD_DIR)/os.iso $(BUILD_DIR)/isofiles

# Linkowanie (Teraz zależy od zmiennej $(OBJECTS))
$(BUILD_DIR)/kernel.bin: $(OBJECTS)
	$(LD) $(LD_FLAGS) -o $@ $(OBJECTS)

# --- REGUŁY KOMPILACJI (PATTERN RULES) ---

# Kompilacja C (Uniwersalna reguła dla każdego pliku .c)
# % to "wildcard". Mówi: "Weź dowolny plik .c i zrób z niego .o w tym samym układzie katalogów"
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@) # Tworzy podkatalog w build/ (np. build/kernel/) jeśli nie istnieje
	$(CC) $(CC_FLAGS) $< -o $@

# Asemblacja (Uniwersalna reguła dla każdego pliku .asm)
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	@mkdir -p $(dir $@)
	$(ASM) $(ASM_FLAGS) -o $@ $<

clean:
	rm -rf $(BUILD_DIR)/*