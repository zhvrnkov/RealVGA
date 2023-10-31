[ORG 0x7C00]
[BITS 16]

%define WIDTH 320
%define HEIGHT 200
%define VGA 0xA000
%define stack1(i) ss:[esp + i]
%define stack2(i) ss:[esp + 2 * i]
%define stack4(i) ss:[esp + 4 * i]

mov ax, 0x0013
int 0x10

xor ax, ax
mov es, ax
mov dword [es:0x0070], draw_frame

jmp $

draw_frame:
    pusha
    push VGA
    pop es
    call draw
    ; mov esp, [stack]

    ; add word [pos_x], 100
    ; add word [pos_y], 100
    ; add byte [color], 1
    ; push word [pos_x] ; y-offset
    ; push word [pos_y] ; x-offset
    ; push 320
    ; push 50 ; height
    ; push 50 ; width
    ; push word [color]
    ; call fill
    ; sub esp, 2 * 6

    popa
    iret

draw:
    inc word [color]
    mov [stack], esp
    push word [color]
    ; sub esp, 2
    ; sub esp, 4
    ; push x
    ; mov [color], word 0x0f
    ; mov cx, 0x0b
    call clear_screen
    mov esp, [stack]
    ret

; main_loop:
;     mov stack2(5), word 0
;     add stack2(4), word 1
;     cmp stack2(4), word 270
    
;     jb .continue
;     mov stack2(4), word 0
;     ; mov stack2(5), word 100
;     ; mov stack2(4), word 100
; .continue:
;     mov stack2(3), word 320
;     mov stack2(2), word 50
;     mov stack2(1), word 50
;     mov stack2(0), word 0x0c
;     call fill

;     ; call clear_screen
;     jmp main_loop

jmp $

; stack[0] = color
; stack[1] = width
; stack[2] = height
; stack[3] = bytesPerRow
; stack[4] = x-offset
; stack[5] = y-offset
fill:
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
    jae .out

    add bx, stack2(4)
    mov ax, 0
    jmp .iter
.out:
    ret

; stack[0] = color
clear_screen:
    mov bx, 0
.iter:
    mov cl, byte stack2(1)
    mov byte [es:bx], cl
    inc bx
    cmp bx, WIDTH * HEIGHT
    jb .iter
    ret
    ; push 0 ; y-offset
    ; push 0 ; x-offset
    ; push 320
    ; push 100 ; height
    ; push 100 ; width
    ; push 0x0d
    ; call fill
    ; ret

pos_x: dw 0
pos_y: dw 0
color: dw 0x00
stack: dw 0
times 510 - ($ - $$) db 0
dw 0xaa55