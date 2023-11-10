[ORG 0x7C00]
[BITS 16]

%macro read_key_press 0
    mov ah, 0x01
    int 0x16
%endmacro

.start:

read_key_press
mov ah, 0x0e
int 0x10
jnz .key_pressed
mov al, 0x0
jmp .start

.key_pressed:
mov ah, 0x00
int 0x16

jmp .start
hlt

times 510 - ($ - $$) db 0
dw 0xaa55