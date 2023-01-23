; assembler directive realmode emit 16bit binary
bits 16

; external symbols defined elsewhere and linked by the linker
extern kernel_main
extern interrupt_handler
extern scheduler
extern run_next_process
extern page_directory

global load_page_directory
global enable_paging

start:
    ; initialize segments
    ; CS was set when we performed a far jump
    mov ax, cs
    mov ds, ax
    mov es, ax

    call load_gdt
    call init_video_mode
    call setup_interrupts
    call enable_protected_mode

load_gdt:
    ; according to Intel's x86 manual it is recommended to disable interrupts
    cli

    ; set GDTR register according to our kernel's GDT table and its size.
    ; when we refer to a label (like GDTR), it gets substituted with full
    ; memory address. 
    ; NASM derenferencing (square brackets) in realmode consults the segment
    ; register DS and considers the address an offset.
    lgdt [gdtr]

    sti                 ; enable interrupts

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
    cli                 ; disable interrupts

    ; control registers eg. CR0 detemine the behavior of the processor
    ; control registers are 32bit and can not be manipulated directly
    ; CR0 bit index 0 sets protected-mode, below we make sure its enabled
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; far jump after enabling protected mode
    ; 0x08 is the segment selector of kernel's code as specified in the GDT
    ; any logical memory address that refers to the kernel's code should refer
    ; to the segment selector 0x08 which is the location of kernel's code
    ; segment in the GDT
    ; after far jump, the processor loads the segment selector to CS
    call 0x08:start_kernel

setup_interrupts:
    call remap_pic
    call load_idt
    ret

remap_pic:
    ; PIC init command makes the PIC wait for 3 extra "initialisation words"
    ; on the data port:
    ; (1) vector offset
    ; (2) how it is wired to master/slaves
    ; (3) additional information about the environment
    mov al, 0x11        ; init PIC command code

    ; init trigger
    ; x86 out instruction writes on given I/O port located
    ; in the processor's I/O address space
    out 0x20, al        ; send init command to master PIC command port 0x20
    out 0xa0, al        ; send init command to slave PIC command port 0xa0

    ; init(1)
    ; set master PIC IRQ0 offset to 0x20 (eg. IRQ0 -> int num 32, IRQ1->33)
    mov al, 0x20        ; master IRQ starting offset
    out 0x21, al        ; send to master PIC data port 0x21
    ; set slave PIC IRQ0 offset to 0x28 (eg. IRQ0 -> int num 40, IRQ1->41)
    mov al, 0x28        ; slave IRQ starting offset
    out 0xa1, al        ; send to slave PIC data port 0xa1

    ; init(2)
    ; tell master PIC in which slot slave PIC is connected
    ; slave is connected to master IRQ2
    mov al, 0x04        ; 0x04 = 0000 0100 -> IRQ2 bit is on
    out 0x21, al
    ; tell slave PIC in which slot on master PIC it is connected
    mov al, 0x02        ; connected to IRQ2 on master
    out 0xa1, al

    ; init(3)
    mov al, 0x01        ; set arch to x86 mode
    out 0x21, al        ; set master PIC arch to x86
    out 0xa1, al        ; set slave PIC arch to x86

    mov al, 0x00
    out 0x21, al        ; enable all IRQs on master PIC
    out 0xa1, al        ; enable all IRQs on slave PIC

    ret

load_idt:
    ; check load_gdt for more info
    lidt [idtr]
    ret

; now we run in 32bit protected mode
bits 32

setup_task_register:
    mov ax, 0x28        ; TSS descriptor is in 6th index in GDT (40d=5*8)
    ltr ax              ; load task register
    ret

load_page_directory:
    ; move contents of page_directory to CR3
    mov eax, [page_directory]
    mov cr3, eax
    ret

enable_paging:
    ; enable paging by setting last bit (bit 31) of CR0
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    ret

start_kernel:
    ; same as we set code segment selector to 0x08
    ; the data segment is set to 0x10 (16d bytes in the GDT)
    mov eax, 0x10
    mov ds, eax
    mov ss, eax
    mov es, eax
    mov fs, eax
    mov gs, eax

    ; set ESP
    mov ebp, 0x9000
    mov esp, ebp

    call setup_task_register

    sti                 ; enable interrupts

    call kernel_main

%include "src/gdt.asm"
%include "src/idt.asm"

; https://stackoverflow.com/questions/54876039/creating-a-proper-task-state-segment-tss-structure-with-and-without-an-io-bitm
tss:
    .back_link: dd 0
    .esp0:      dd 0              ; Kernel stack pointer used on ring transitions
    .ss0:       dd 0              ; Kernel stack segment used on ring transitions
    .esp1:      dd 0
    .ss1:       dd 0
    .esp2:      dd 0
    .ss2:       dd 0
    .cr3:       dd 0
    .eip:       dd 0
    .eflags:    dd 0
    .eax:       dd 0
    .ecx:       dd 0
    .edx:       dd 0
    .ebx:       dd 0
    .esp:       dd 0
    .ebp:       dd 0
    .esi:       dd 0
    .edi:       dd 0
    .es:        dd 0
    .cs:        dd 0
    .ss:        dd 0
    .ds:        dd 0
    .fs:        dd 0
    .gs:        dd 0
    .ldt:       dd 0
    .trap:      dw 0
    .iomap_base:dw TSS_SIZE         ; IOPB offset
    ;.cetssp:    dd 0               ; Need this if CET is enabled

    TSS_SIZE EQU $-tss
