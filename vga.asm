; [ORG 0x7C00]
[BITS 16]

%define WIDTH 320
%define HEIGHT 200
%define VGA 0xA000
%define stack1(i) ss:[esp + i]
%define stack2(i) ss:[esp + 2 * i]
%define stack4(i) ss:[esp + 4 * i]

push 100 ; y-offset
push 50 ; x-offset
push 320
push 100 ; height
push 100 ; width
push 0x0c
call fill

jmp $

; stack[0] = color
; stack[1] = width
; stack[2] = height
; stack[3] = bytesPerRow
; stack[4] = x-offset
; stack[5] = y-offset
fill:
    mov ax, 0x0013
    int 0x10
    push VGA
    pop es

    mov di, stack2(6)
    mov ax, stack2(4)
    mul di
    add ax, stack2(5)
    mov bx, ax ; i
    mov ax, 0 ; x
    mov di, 0 ; y

    mov si, stack2(2)
    sub stack2(4), si
    mov cx, stack2(1)
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