; [ORG 0x7C00]
[BITS 16]

%define WIDTH 320
%define HEIGHT 200
%define VGA 0xA000
%define stack1(i) ss:[esp + i]
%define stack2(i) ss:[esp + 2 * i]
%define stack4(i) ss:[esp + 4 * i]

push 320
push 200 ; height
push 160 ; width
push 0x0c
call fill

jmp $

; stack[0] = color
; stack[1] = width
; stack[2] = height
; stack[3] = bytesPerRow
fill:
    mov ax, 0x0013
    int 0x10
    push VGA
    pop es

    mov bx, stack2(2)
    sub stack2(4), bx
    mov cx, stack2(1)

    mov ax, 0 ; x
    mov di, 0 ; y
    mov bx, 0 ; i
.iter:
    mov byte [es:bx], cl
    inc bx
    inc ax
    cmp ax, stack2(2)
    jb .iter
    inc di
    cmp di, stack2(3)
    ja .out
    add bx, stack2(4)
    mov ax, 0
    jmp .iter
.out:
    ret

times 510 - ($ - $$) db 0
dw 0xaa55