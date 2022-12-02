; assembler directive
; this tells the assembler where our code will be loaded
; to add a logical offset to compensate for the actual offset
org 0x7C00

; assembler directive
; make no guesses, emit 16bit binary
bits 16

start:
    ; bios stores boot drive in DL at start
    ; this is the only register value we can rely
    ; on the bios to set
    mov [BOOT_DRIVE], dl

    ; set stack base pointer BP
    mov bp, 0x7C00

    ; initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; setup the stack before bootloader SS:SP 0x0000:0x7C00
    ; cli for legacy compatibility where interrupts are not
    ; blocked for 1 instruction after setting ss
    cli
    mov ss, ax
    mov sp, bp                                  ; stack grows downwards from 0x7C00
    sti

    ; clear direction flag so string operations 
    ; increment the index registers SI/DI
    cld

    mov si, TITLE_STR
    call print_str

    mov si, LOADING_STR
    call print_str

    call load_kernel_to_mem
    jmp 0x0900:0x00

; load kernel
load_kernel_to_mem:
    ; bios service 0x13:0x02 reads from disk to
    ; memory address ES:BX
    mov ax, 0x0900
    mov es, ax

    mov ah, 0x02                                ; read sectors from disk into mem
    mov al, 0x01                                ; sectors to read count
    mov ch, 0x00                                ; track
    mov cl, 0x02                                ; sector
    mov dh, 0x00                                ; head
    mov dl, [BOOT_DRIVE]                        ; disk type 1st hard disk
    mov bx, 0x00                                ; offset (ES:BX)
    int 0x13                                    ; 0x13:0x02 sets CF=0 on success, otherwise CF=1 AX=errno
    jc handle_load_err                          ; handle error if CF=1
    ret

handle_load_err:
    mov si, ERR_LOAD_STR
    call print_str
    hlt                                         ; stop cpu from executing further instruction (breaks on interrupts)

; print a string to the screen
; params:
;   - DS:SI points to a null terminated string
print_str:
    mov ah, 0x0E                                ; teletype output
.loop lodsb                                     ; load byte from SI to AL then advance SI
    test al, al                                 ; set ZF to 1 if AL == 0
    jz finished_printing                        ; jmp if ZF == 1
    int 0x10                                    ; print byte to screen
    jmp .loop

finished_printing:
    mov al, 10d                                 ; print new line
    int 0x10
    mov ah, 0x03                                ; get cursor position and shape
    mov bh, 0                                   ; page number
    int 0x10
    mov ah, 0x02                                ; set cursor position
    mov dl, 0                                   ; col 0
    int 0x10
    ret

; data after code 
BOOT_DRIVE          db 0
TITLE_STR           db "Bootloader for Curn", 0
LOADING_STR         db "Loading Curn...", 0
ERR_LOAD_STR        db "Failed to load Curn", 0

; the bootloader sector must end with the magic code 0xAA55
; ($-$$) nasm special expression to calculate program size in bytes
times 510 - ($ - $$) db 0                       ; set 0 from bootloader code end till byte 510
dw 0xAA55                                       ; set magic code in last 2 bytes 
