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
    jmp 0x0900:0x0000

; load kernel
load_kernel_to_mem:
    ; read multiple sectors
    mov ax, [CURR_SECTOR_TO_READ]
    sub ax, 2
    mov bx, 0x0200                              ; 512 bytes
    mul bx                                      ; implicitly uses AX as second operand and stores result in DX:AX
    mov bx, ax                                  ; offset [0, 512, 1024, ...]

    ; bios service 0x13:0x02 reads from disk to
    ; memory address ES:BX
    mov ax, 0x0900
    mov es, ax

    mov ah, 0x02                                ; service to read from disk to memory
    mov al, 0x01                                ; sectors to read count
    mov ch, 0x00                                ; track
    mov cl, [CURR_SECTOR_TO_READ]               ; sector
    mov dh, 0x00                                ; head
    mov dl, [BOOT_DRIVE]                        ; disk type 1st hard disk
    int 0x13                                    ; 0x13:0x02 sets CF=0 on success, otherwise CF=1 AX=errno
    jc handle_load_err                          ; handle error if CF=1

    ; decrese num sectors left to read, increase current sector
    sub byte [NUM_SECTORS], 1
    add byte [CURR_SECTOR_TO_READ], 1
    cmp byte [NUM_SECTORS], 0
    jne load_kernel_to_mem

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
TITLE_STR           db "Running bootloader", 0
LOADING_STR         db "Loading kernel...", 0
ERR_LOAD_STR        db "Failed to load kernel", 0
NUM_SECTORS         db 0x0f                     ; 15 sectors = 7.5kb
CURR_SECTOR_TO_READ db 0x02


; the bootloader sector must end with the magic code 0xAA55
; ($-$$) nasm special expression to calculate program size in bytes
times 510 - ($ - $$) db 0                       ; set 0 from bootloader code end till byte 510
dw 0xAA55                                       ; set magic code in last 2 bytes 
