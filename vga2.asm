    org 0x7C00
%define WIDTH 320
%define HEIGHT 200

%define BALL_WIDTH 10
%define BALL_HEIGHT 10

    mov ax, 0x0013
    int 0x10

    xor ax, ax
    mov es, ax
    mov word [es:0x0070], draw_frame
    mov word [es:0x0072], 0x00

    jmp $

draw_frame:
    pusha

    mov ax, 0xA000
    mov es, ax

    call clear_screen

    popa
    iret

clear_screen:
    mov bx, 0
.iter:
    mov byte [es:bx], 0x0c
    inc bx
    cmp bx, WIDTH * HEIGHT
    jb .iter
    ret


times 510 - ($-$$) db 0
dw 0xaa55