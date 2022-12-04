; kernel GDT table, contains 5 entries, employs a flat memory model
; info: https://wiki.osdev.org/Global_Descriptor_Table
gdt:
    ; null descriptor is a requisite first entry in x86 GDT
    null_descriptor                 : dw 0, 0, 0, 0
    ; offset=0x08 base=0x00 limit=0xfffff granularity=4kb (4gb mem)
    ; system-segment=false type=code accessed=false read/write=true
    ; expand-direction=none opsize=32bit 64bit=false
    kernel_code_descriptor          : dw 0xffff, 0x0000, 0x9a00, 0x00cf
    ; offset=0x10 base=0x00 limit=0xfffff granularity=4kb (4gb mem)
    ; system-segment=false type=data accessed=false read/write=true
    ; expand-direction=up opsize=4gb 64bit=false
    kernel_data_descriptor          : dw 0xffff, 0x0000, 0x9200, 0x00cf
    ; offset=0x18 base=0x00 limit=0xfffff granularity=4kb (4gb mem)
    ; system-segment=false type=code accessed=false read/write=true
    ; expand-direction=none opsize=32bit 64bit=false
    userspace_code_descriptor       : dw 0xffff, 0x0000, 0xfa00, 0x00cf
    ; offset=0x20 base=0x00 limit=0xfffff granularity=4kb (4gb mem)
    ; system-segment=false type=data accessed=false read/write=true
    ; expand-direction=up opsize=4gb 64bit=false
    userspace_data_descriptor       : dw 0xffff, 0x0000, 0xf200, 0x00cf

; GDTR contents
gdtr:
    ; gdt table size = num_entries * entry_size_in_bytes
    gdt_size_in_bytes               : dw (5 * 8)
    ; set *physical* memory address
    ; when the processor tries to reach GDT it
    ; doesn't consult any segment registers
    ; dd=define double word (4 bytes on a typical x86 32bit system)
    gdt_base_address                : dd gdt

