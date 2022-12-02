bits 16

start:
    ; set data segment start
    mov ax, 0x0900
    mov ds, ax

    mov si, hello_str
    call print_str
    jmp $

print_str:
    mov ah, 0x0E                                ; teletype output
.loop lodsb                                     ; load byte from si to al then advance si
    cmp al, 0                                   ; cmp loaded byte to 0
    je done                                     ; jmp if curr byte is 0
    int 0x10                                    ; print byte to screen
    jmp .loop

done:
    ret

hello_str   db "Hello World!", 0

