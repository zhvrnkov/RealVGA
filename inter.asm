org 0x7C00

BITS 16

start:
    ; Set up GDT
    lgdt [gdt_descriptor]

    ; Set up IDT
    lidt [idt_descriptor]

    ; Configure the PIT
    mov al, 0x36    ; Set timer channel 0, mode 3, binary counter
    out 0x43, al

    mov al, 0x4C    ; Set the desired frequency (e.g., 100 Hz)
    out 0x40, al
    mov al, ah
    out 0x40, al

    ; Enable interrupts
    sti

    ; Infinite loop
    cli
    hlt

gdt_descriptor:
    dw $ - gdt - 1
    dd gdt

gdt:
    ; GDT entry for code segment
    dw 0xFFFF    ; Limit
    dw 0x0000    ; Base
    db 0x00      ; Base
    db 0x9A      ; Access byte
    db 0xCF      ; Granularity byte
    db 0x00      ; Base

idt_descriptor:
    dw $ - idt - 1
    dd idt

idt:
    times 256 dw interrupt_handler    ; IDT entries, each pointing to interrupt_handler
interrupt_handler:                    ; Timer interrupt handler
    ; Save CPU state
    pusha

    ; Perform operations

    ; End of interrupt
    mov al, 0x20
    out 0x20, al

    ; Restore CPU state
    popa
    iret

times 510-($-$$) db 0
dw 0xAA55    ; Boot signature
