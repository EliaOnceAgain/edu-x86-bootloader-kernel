; assembler directive realmode emit 16bit binary
bits 16

; external symbols defined elsewhere and linked by the linker
extern kernel_main

start:
    ; initialize segments
    ; CS was set when we performed a far jump
    mov ax, cs
    mov ds, ax
    mov es, ax

    call load_gdt
    call init_video_mode
    call enable_protected_mode
    call setup_interrupts

    ; far jump after enabling protected mode
    ; 0x08 is the segment selector of kernel's code as specified in the GDT
    ; any logical memory address that refers to the kernel's code should refer
    ; to the segment selector 0x08 which is the location of kernel's code
    ; segment in the GDT
    ; after far jump, the processor loads the segment selector to CS
    call 0x08:start_kernel

load_gdt:
    ; according to Intel's x86 manual it is recommended to disable interrupts
    cli

    ; set GDTR register according to our kernel's GDT table and its size.
    ; when we refer to a label (like GDTR), it gets substituted with full
    ; memory address. 
    ; NASM derenferencing (square brackets) in realmode consults the segment
    ; register DS and considers the address an offset.
    ; so when we refer to GDTR we need to supply an offset from DS (our data
    ; segment); hence the [GDTR - start]
    lgdt [gdtr - start]
    ret

init_video_mode:
    ; bios service 0x10:0x00 specify display mode
    ; AL = desired video mode 0x03 16 colors text mode resolution 80x25
    ; in text mode 0x03 each printed character is encoded in 2 bytes
    ; 1st byte is character's ascii code, 2nd byte is bg/fg colors
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; disable text input cursor
    mov ah, 0x01
    mov cx, 0x2000
    int 0x10

    ret

enable_protected_mode:
    ; control registers eg. CR0 detemine the behavior of the processor
    ; control registers are 32bit and can not be manipulated directly
    ; CR0 bit index 0 sets protected-mode, below we make sure its enabled
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    ret

setup_interrupts:
    ret

; now we run in 32bit protected mode
bits 32
start_kernel:
    ; same as we set code segment selector to 0x08
    ; the data segment is set to 0x10 (16d bytes in the GDT)
    mov eax, 0x10
    mov ds, eax
    mov ss, eax

    mov eax, 0x00
    mov es, eax
    mov fs, eax
    mov gs, eax

    call kernel_main

%include "kernel/gdt.asm"
