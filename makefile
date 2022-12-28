# Compiler, Linker, and Assembler
ASM         = nasm
CC          = gcc
LNK         = ld

# Target program name
TARGET		:= kernel.img

# DIRS
SRCDIR      := src
INCDIR      := inc
BUILDDIR    := obj
TARGETDIR   := bin
SRCEXT		:= c
OBJEXT		:= o

# Flags
# -Wall: enable all warnings
# -m32: generate 32bit code
# -ffreestanding: target a freestanding env where std lib does not exist
# -fno-pie: disable pie compilation (-no-pie for linker)
CFLAGS      := -Wall -m32 -ffreestanding -fno-asynchronous-unwind-tables -fno-pie -c
LDFLAGS     := -Tlinker.ld -melf_i386
INC			:= -I$(INCDIR)

BOOTLOADER  = bootloader.asm
INIT_KERNEL = kernel_init.asm

# Collect *.$(SRCEXT)
SOURCES     := $(shell find $(SRCDIR) -type f -name "*.$(SRCEXT)")
OBJECTS     := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.$(OBJEXT)))

# Default
all: $(TARGETDIR)/$(TARGET)

# Assemble bootloader
$(BUILDDIR)/$(BOOTLOADER:.asm=): $(SRCDIR)/$(BOOTLOADER) $(SRCDIR)/$(INIT_KERNEL)
	$(ASM) -f bin $(SRCDIR)/$(BOOTLOADER) -o $(BUILDDIR)/$(BOOTLOADER:.asm=)

# Assemble kernel init
$(BUILDDIR)/$(INIT_KERNEL:.asm=.o): $(SRCDIR)/$(INIT_KERNEL)
	$(ASM) -f elf32 $(SRCDIR)/$(INIT_KERNEL) -o $(BUILDDIR)/$(INIT_KERNEL:.asm=.o)

# Compile
$(BUILDDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(SRCEXT)
	$(CC) $(CFLAGS) $(INC) -o $@ $<

# Link and build kernel img
$(TARGETDIR)/$(TARGET): dirs $(BUILDDIR)/$(BOOTLOADER:.asm=) $(BUILDDIR)/$(INIT_KERNEL:.asm=.o) $(OBJECTS)
	$(LNK) $(LDFLAGS) $(BUILDDIR)/*.$(OBJEXT) -o kernel.elf

	# no elf interpreter available, convert to flat binary
	objcopy -O binary kernel.elf kernel.bin

	dd if=$(BUILDDIR)/$(BOOTLOADER:.asm=) of=$(TARGETDIR)/$(TARGET)
	dd seek=1 conv=sync if=kernel.bin of=$(TARGETDIR)/$(TARGET) bs=512 count=5

	# cleanup
	rm -rf kernel.bin kernel.elf

	@echo "build: Success"

run: $(TARGETDIR)/$(TARGET)
	qemu-system-x86_64 -s $(TARGETDIR)/$(TARGET)

dirs:
	@mkdir -p $(TARGETDIR)
	@mkdir -p $(BUILDDIR)

clean:
	rm -f *.o *.elf *.img *.bin
	rm -rf obj/ bin/

.PHONY: all dirs clean
