; [ORG 0x7C00]
[BITS 16]

%define WIDTH 320
%define HEIGHT 200
%define VGA 0xA000
%define stack1(i) ss:[esp + i]
%define stack2(i) ss:[esp + 2 * i]
%define stack4(i) ss:[esp + 4 * i]

push 30
push 320
push 0x0c
call fill

jmp $

; stack[0] = color
; stack[1] = width
; stack[2] = height
fill:
    mov cx, stack2(1)

    mov ax, stack2(2) ; ax = width
    mul word stack2(3)
    push ax ; word 320 * 100

    mov bx, 0
    mov ax, 0x0013
    int 0x10
    push VGA
    mov es, stack2(0)
.y_iter:
    mov byte [es:bx], cl
    inc bx
    cmp bx, stack2(1)
    jb .y_iter
    ret

times 510 - ($ - $$) db 0
dw 0xaa55