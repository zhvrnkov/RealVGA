[ORG 0x7C00]
[BITS 16]

%define VGA 0xA000
%define WIDTH 320
%define HEIGHT 200
%define RECT_WIDTH 2
%define RECT_HEIGHT 2
%define stack1(i) ss:[esp + i]
%define stack2(i) ss:[esp + 2 * i]
%define stack4(i) ss:[esp + 4 * i]

; enter vga mode
mov ax, 0x0013
int 0x10

; clear the es register
xor ax, ax
mov es, ax

cli
; set interrupt routine
mov dword [es:0x0070], main_loop

mov dword [es:4 * 9], keyboard_handler
mov [es:4 * 9 + 2], cs

sti

jmp $

main_loop:
    pusha
    push VGA
    pop es

    call draw_frame

    popa
    iret

draw_frame:
    mov ebp, esp

    call clear_screen

;     mov ax, [player_dx]
;     add word [player_x], ax

;     cmp word [player_x], HEIGHT - RECT_HEIGHT
;     jb .c1
;     neg word [player_dx]
; .c1:
;     cmp word [player_x], 0
;     ja .c2
;     neg word [player_dx]
; .c2:

;     mov ax, [player_dy]
;     add word [player_y], ax

;     cmp word [player_y], WIDTH - RECT_WIDTH
;     jb .c3
;     neg word [player_dy]
; .c3:
;     cmp word [player_y], 0
;     ja .c4
;     neg word [player_dy]
; .c4:
.update_food_x:
    mov ax, [food_dx]
    add word [food_x], ax
    cmp word [food_x], WIDTH - 10
    ja .neg_food_dx
    jmp .update_food_y
.neg_food_dx:
    neg word [food_dx]
    mov ax, [food_dx]
    add word [food_x], ax
    inc word [food_color]
.update_food_y:
    mov ax, [food_dy]
    add word [food_y], ax
    cmp word [food_y], HEIGHT - 10
    ja .neg_food_dy
    jmp .end_update_food
.neg_food_dy:
    neg word [food_dy]
    mov ax, [food_dy]
    add word [food_y], ax
    inc word [food_color]
.end_update_food:

    push word [food_y]
    push word [food_x]
    push 10
    push 10
    push word [food_color]
    call fill
    mov esp, ebp

    mov ax, word [player_dx]
    add word [player_x], ax
    mov ax, word [player_dy]
    add word [player_y], ax

    mov ax, word [player_y]
    mov bx, HEIGHT
    call moda
    mov word [player_y], ax

    mov ax, word [player_x]
    mov bx, WIDTH
    call moda
    mov word [player_x], ax

    push word [player_y] ; y-offset
    push word [player_x] ; x-offset
    push word [player_h] ; height
    push word [player_w] ; width
    push 0x04
    call fill
    mov esp, ebp

    ret

keyboard_handler:
    pusha
    in al, 0x60

    mov bx, 1
    test al, 0x80
    jz .checks
    mov bx, 0
    and al, ~0x80

.checks:
    xor ah, ah
.check_w:
    cmp ax, 17
    jne .check_a
    neg bx
    mov word [player_dy], bx
.check_a:
    cmp ax, 30
    jne .check_s
    neg bx
    mov word [player_dx], bx
.check_s:
    cmp ax, 31
    jne .check_d
    mov word [player_dy], bx
.check_d:
    cmp ax, 32
    jne .end
    mov word [player_dx], bx

.end:
    mov al, 0x61
    out 20h, al
    popa
    iret

jmp $

; stack[1] = color
; stack[2] = width
; stack[3] = height
; stack[4] = x-offset
; stack[5] = y-offset
fill:
    mov si, 0 ; rows-count = 0
.recalc_i:
    mov dx, 0              ; cols-count = 0
.recalc_i2:
    mov di, stack2(5)      ; di = y-offset
    add di, si             ; di += rows-count
    mov ax, stack2(4)      ; ax = x-offset
    add ax, dx
    push dx
    call calc_i            ; ax = i
    pop dx
    mov bx, ax             ; bx = ax = i
.iter:

    mov cx, stack2(1)      ; cx = color
    mov byte [es:bx], cl   ; draw at i with color 

    inc dx                 ; dx = cols-count => cols-count++
    cmp dx, stack2(2)      ; if cols-count < width => draw another
    jb .recalc_i2
    
    inc si                 ; rows-count ++
    cmp si, stack2(3)      ; if rows-count < height => draw another row
    jb .recalc_i

    ret

clear_screen:
    mov bx, 0
.iter:
    mov byte [es:bx], 0x00
    inc bx
    cmp bx, WIDTH * HEIGHT
    jb .iter
    ret

; ax = x
; bx = y
; result in ax = x % y
moda:
    add ax, bx
    xor dx, dx
    div bx
    mov ax, dx
    ret

; ax = a
; bx = b
; cx = c
; result in ax = a * b + c
ima:
    xor dx, dx
    mul bx
    add ax, cx
    ret

; ax = x
; di = y
; i = (y % HEIGHT) * bytesPerRow + (x % WIDTH)
calc_i:
    mov ax, ax
    mov bx, WIDTH
    call moda
    push ax

    mov ax, di
    mov bx, HEIGHT
    call moda
    push ax

    pop ax ; ax = y
    pop cx ; cx = x
    mov bx, 320 ; bytes per row
    call ima ; ax = ax * bx + cx
    ret

player_x: dw 0
player_y: dw 100 
player_w: dw 2
player_h: dw 2
player_dx: dw 0 
player_dy: dw 0

food_x: dw 34
food_y: dw 30

food_dx: dw 4
food_dy: dw 4

food_color: dw 0

color: dw 0x00
times 510 - ($ - $$) db 0
dw 0xaa55