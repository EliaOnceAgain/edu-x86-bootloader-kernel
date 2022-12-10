ASM         = nasm
CC          = gcc

BOOTLOADER  = bootloader/stage1_bootloader.asm
INIT_KERN   = bootloader/stage2_bootloader.asm
KERN        = kernel/main.c

KERN_OBJ    = -o kernel.elf

# -Wall: enable all warnings
# -m32: generate 32bit code
# -ffreestanding: target a freestanding env where std lib does not exist
# -fno-pie: disable pie compilation (-no-pie for linker)
CFLAGS      := -Wall -m32 -ffreestanding -fno-asynchronous-unwind-tables -fno-pie
LDFLAGS     := -Tlinker.ld

build: $(BOOTLOADER) $(INIT_KERN) $(KERN)
	$(ASM) -f bin $(BOOTLOADER) -o bootloader.o
	$(ASM) -f elf32 $(INIT_KERN) -o starter.o
	$(CC) $(CFLAGS) -c $(KERN) $(KERN_OBJ)
	ld $(LDFLAGS) -melf_i386 starter.o kernel.elf -o curn.elf

	# no elf interpreter available, convert to flat binary
	objcopy -O binary curn.elf curn.bin

	dd if=bootloader.o of=kern.img
	dd seek=1 conv=sync if=curn.bin of=kern.img bs=512 count=5
	@echo "build: Success"

run: build
	qemu-system-x86_64 -s kern.img

clean:
	rm -f *.o *.elf *.img *.bin

