; two sources of interrupts: software and hardware, hardware interrupts
; happen through a device connected to the processor called
; PIC - programmable interrupts controller
; which is a mediator between the machine's IO devices and the processor.
; interrupt requests (IRQ) are sent to PIC which sends them to the processor.
; in protected mode, software and hardware interrupt numbers may conflict,
; thus we remapped the PIC to change default mappings of IRQs to processor
; interrupt number.

; ISRs 0-31 are related to the processor
isr_0:
    cli             ; while handling an interrupt no other interrupt may occur
    push 0          ; push the int num to the stack for the interrupt handler
    jmp isr_basic

isr_1:
    cli
    push 1
    jmp isr_basic

isr_2:
    cli
    push 2
    jmp isr_basic

isr_3:
    cli
    push 3
    jmp isr_basic

isr_4:
    cli
    push 4
    jmp isr_basic

isr_5:
    cli
    push 5
    jmp isr_basic

isr_6:
    cli
    push 6
    jmp isr_basic

isr_7:
    cli
    push 7
    jmp isr_basic

isr_8:
    cli
    push 8
    jmp isr_basic

isr_9:
    cli
    push 9
    jmp isr_basic

isr_10:
    cli
    push 10
    jmp isr_basic

isr_11:
    cli
    push 11
    jmp isr_basic

isr_12:
    cli
    push 12
    jmp isr_basic

isr_13:
    cli
    push 13
    jmp isr_basic

isr_14:
    cli
    push 14
    jmp isr_basic

isr_15:
    cli
    push 15
    jmp isr_basic

isr_16:
    cli
    push 16
    jmp isr_basic

isr_17:
    cli
    push 17
    jmp isr_basic

isr_18:
    cli
    push 18
    jmp isr_basic

isr_19:
    cli
    push 19
    jmp isr_basic

isr_20:
    cli
    push 20
    jmp isr_basic

isr_21:
    cli
    push 21
    jmp isr_basic

isr_22:
    cli
    push 22
    jmp isr_basic

isr_23:
    cli
    push 23
    jmp isr_basic

isr_24:
    cli
    push 24
    jmp isr_basic

isr_25:
    cli
    push 25
    jmp isr_basic

isr_26:
    cli
    push 26
    jmp isr_basic

isr_27:
    cli
    push 27
    jmp isr_basic

isr_28:
    cli
    push 28
    jmp isr_basic

isr_29:
    cli
    push 29
    jmp isr_basic

isr_30:
    cli
    push 30
    jmp isr_basic

isr_31:
    cli
    push 31
    jmp isr_basic

isr_32:                             ; system timer interrupt
    ; values stored by the suspended process on the general purpose registers
    ; will be there when isr_32 starts executing, and the processor does
    ; not change any of them when suspending the process and calling interrupt
    ; handler.
    ; This is due to the fact that we defined all ISRs gate descriptors as
    ; interrupt gates in the IDT table.
    ; if we were to define them as task gates instead, the context of the
    ; suspended process will not be available on the processor's registers.
    ; defining an ISR descriptor as an interrupt gate makes the processor
    ; call this ISR as a normal routine following normal calling conventions.
    cli                             ; disable interrupts while handling one

    ; push current values of all general purpose registers into the stack
    ; the opposite of pusha is popa, pop from stack into the registers
    ; order: eax, ecx, edx, ebx, esp, ebp, esi, edi
    ; based on the calling convention, they will be received as paramters
    ; in revered order (see scheduler() signature in scheduler.c)
    pusha                           ; push all

    ; calling convention again, EIP gets pushed prior to calling the interrupt
    ; handler, afterwards we stored 8 registers, so to get the EIP
    ; before the interrupt handler was called we do ESP + 8registers * 4bytes
    ; since EIP is pushed last, it is the first arg in scheduler() signature
    mov eax, [esp + 32]
    push eax

    call scheduler

    ; tell PIC interrupt handling is done (see irq_basic below)
    mov al, 0x20
    out 0x20, al

    ; remove all pushed values on the stack while running isr_32 by adding
    ; 40d to the current value of ESP
    ; 40 = 8registers * 4bytes + EIP * 4bytes + previous EIP * 4bytes
    ; the previous EIP is removed because we want to set a new EIP of the
    ; new process (and not continue the last process)
    add esp, 0x28

    ; the new EIP is the memory address of run_next_process
    push run_next_process

    iret

isr_33:
    cli
    push 33
    jmp irq_basic

isr_34:
    cli
    push 34
    jmp irq_basic

isr_35:
    cli
    push 35
    jmp irq_basic

isr_36:
    cli
    push 36
    jmp irq_basic

isr_37:
    cli
    push 37
    jmp irq_basic

isr_38:
    cli
    push 38
    jmp irq_basic

isr_39:
    cli
    push 39
    jmp irq_basic

isr_40:
    cli
    push 40
    jmp irq_basic

isr_41:
    cli
    push 41
    jmp irq_basic

isr_42:
    cli
    push 42
    jmp irq_basic

isr_43:
    cli
    push 43
    jmp irq_basic

isr_44:
    cli
    push 44
    jmp irq_basic

isr_45:
    cli
    push 45
    jmp irq_basic

isr_46:
    cli
    push 46
    jmp irq_basic

isr_47:
    cli
    push 47
    jmp irq_basic

isr_48:
    cli
    push 48
    jmp irq_basic

isr_basic:
    call interrupt_handler
    pop eax
    sti                     ; re-enable interrupts
    iret                    ; iret = ret + reset the interrupt enable (IEN)

irq_basic:
    call interrupt_handler

    ; IRQs coming from system PICs requires handle done reply
    ; for that we use PIC end-of-interrupt (EOI) command
    ; master PIC requires answers to ALL interrupts
    ; slave PIC requries answers only to interrupts it initiates (IRQ 40-48)
    mov al, 0x20            ; here 0x20 is EOI command
    out 0x20, al            ; here 0x20 is master PIC commands port

    cmp byte [esp], 0x28    ; check if IRQ>=40
    jnge irq_basic_end      ; if IRQ < 40 skip sending EOI to slave PIC

    mov al, 0x20            ; EOI command 0x20
    out 0xa0, al            ; send EOI through slave pic command port

    irq_basic_end:
        pop eax
        sti
        iret

idt:
    ; isr_x             : handler name
    ; 8                 : segment selector (kernel's code)
    ; present           : yes
    ; privilege level   : 0
    ; descriptor size   : 32bit
    ; gate type         : interrupt
    dw isr_0, 8, 0x8e00, 0x0000
    dw isr_1, 8, 0x8e00, 0x0000
    dw isr_2, 8, 0x8e00, 0x0000
    dw isr_3, 8, 0x8e00, 0x0000
    dw isr_4, 8, 0x8e00, 0x0000
    dw isr_5, 8, 0x8e00, 0x0000
    dw isr_6, 8, 0x8e00, 0x0000
    dw isr_7, 8, 0x8e00, 0x0000
    dw isr_8, 8, 0x8e00, 0x0000
    dw isr_9, 8, 0x8e00, 0x0000
    dw isr_10, 8, 0x8e00, 0x0000
    dw isr_11, 8, 0x8e00, 0x0000
    dw isr_12, 8, 0x8e00, 0x0000
    dw isr_13, 8, 0x8e00, 0x0000
    dw isr_14, 8, 0x8e00, 0x0000
    dw isr_15, 8, 0x8e00, 0x0000
    dw isr_16, 8, 0x8e00, 0x0000
    dw isr_17, 8, 0x8e00, 0x0000
    dw isr_18, 8, 0x8e00, 0x0000
    dw isr_19, 8, 0x8e00, 0x0000
    dw isr_20, 8, 0x8e00, 0x0000
    dw isr_21, 8, 0x8e00, 0x0000
    dw isr_22, 8, 0x8e00, 0x0000
    dw isr_23, 8, 0x8e00, 0x0000
    dw isr_24, 8, 0x8e00, 0x0000
    dw isr_25, 8, 0x8e00, 0x0000
    dw isr_26, 8, 0x8e00, 0x0000
    dw isr_27, 8, 0x8e00, 0x0000
    dw isr_28, 8, 0x8e00, 0x0000
    dw isr_29, 8, 0x8e00, 0x0000
    dw isr_30, 8, 0x8e00, 0x0000
    dw isr_31, 8, 0x8e00, 0x0000
    dw isr_32, 8, 0x8e00, 0x0000
    dw isr_33, 8, 0x8e00, 0x0000
    dw isr_34, 8, 0x8e00, 0x0000
    dw isr_35, 8, 0x8e00, 0x0000
    dw isr_36, 8, 0x8e00, 0x0000
    dw isr_37, 8, 0x8e00, 0x0000
    dw isr_38, 8, 0x8e00, 0x0000
    dw isr_39, 8, 0x8e00, 0x0000
    dw isr_40, 8, 0x8e00, 0x0000
    dw isr_41, 8, 0x8e00, 0x0000
    dw isr_42, 8, 0x8e00, 0x0000
    dw isr_43, 8, 0x8e00, 0x0000
    dw isr_44, 8, 0x8e00, 0x0000
    dw isr_45, 8, 0x8e00, 0x0000
    dw isr_46, 8, 0x8e00, 0x0000
    dw isr_47, 8, 0x8e00, 0x0000
    dw isr_48, 8, 0x8e00, 0x0000

; label idtr must be right below label idt
; for it to automatically detect size (instead of hard coding it)
idtr:
    idt_size_in_bytes   :     dw (idtr - idt - 1)
    idt_base_address    :     dd idt
