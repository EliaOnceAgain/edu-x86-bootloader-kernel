ASM = nasm
BOOTLOADER = bootloader/bootloader.asm
KERN = kernel/dummy_kern.asm

build: $(BOOTLOADER) $(KERN)
	$(ASM) -f bin $(BOOTLOADER) -o bootloader.o
	$(ASM) -f bin $(KERN) -o kern.o
	dd if=bootloader.o of=kern.img
	dd seek=1 conv=sync if=kern.o of=kern.img bs=512
	qemu-system-x86_64 -s kern.img

clean:
	rm -f *.o
