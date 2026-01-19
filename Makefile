run:
	nasm -f elf32 -o build/boot.o src/asm/boot.asm 
	x86_64-elf-gcc -ffreestanding -m32 -c src/c/kernel.c -o build/kernel.o  
	x86_64-elf-ld -m elf_i386 -n -o build/kernel.bin -T targets/link.ld build/boot.o build/kernel.o
	cp build/kernel.bin build/isofiles/boot/kernel.bin  
	i686-elf-grub-mkrescue -o build/os.iso build/isofiles 