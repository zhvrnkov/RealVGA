[ORG 0x7C00]
[BITS 16]

%define VGA 0xA000
%define WIDTH 320
%define HEIGHT 200
%define RECT_WIDTH 50
%define RECT_HEIGHT 50
%define RECT_INIT_DX 5
%define RECT_INIT_DY 5
%define stack1(i) ss:[esp + i]
%define stack2(i) ss:[esp + 2 * i]
%define stack4(i) ss:[esp + 4 * i]

%macro read_key_press 0
    ; xor ax, ax
    ; mov ss, ax
    ; mov sp, 0x0
    mov ah, 0x00
    int 0x16
%endmacro

; enter vga mode
mov ax, 0x0013
int 0x10

; clear the es register
xor ax, ax
mov es, ax

; set interrupt routine
mov dword [es:0x0070], main_loop

jmp $

main_loop:
    pusha
    push VGA
    pop es

    call draw_frame

    popa
    iret

draw_frame:
    xor ax, ax
    mov ah, 0x01
    int 0x16
    jnz .pressed
    jmp .end
.pressed:
    mov ah, 0x00
    int 0x16

    ; update rect position
.check_d:
    cmp al, 'd'
    jne .check_a

    mov ax, [pos_dx]
    add word [pos_x], ax
    jmp .end
.check_a:
    cmp al, 'a'
    jne .check_w

    mov ax, [pos_dx]
    sub word [pos_x], ax
    jmp .end
.check_w:
    cmp al, 'w'
    jne .check_s

    mov ax, [pos_dy]
    sub word [pos_y], ax
    jmp .end
.check_s:
    cmp al, 's'
    jne .end

    mov ax, [pos_dy]
    add word [pos_y], ax
    jmp .end
.end:
    ; pos_y = (pos_y + HEIGHT) % HEIGHT
    mov ax, word [pos_y]
    mov bx, HEIGHT
    call moda
    mov word [pos_y], ax

.end2:
    mov ebp, esp

    call clear_screen

;     mov ax, [pos_dx]
;     add word [pos_x], ax

;     cmp word [pos_x], HEIGHT - RECT_HEIGHT
;     jb .c1
;     neg word [pos_dx]
; .c1:
;     cmp word [pos_x], 0
;     ja .c2
;     neg word [pos_dx]
; .c2:

;     mov ax, [pos_dy]
;     add word [pos_y], ax

;     cmp word [pos_y], WIDTH - RECT_WIDTH
;     jb .c3
;     neg word [pos_dy]
; .c3:
;     cmp word [pos_y], 0
;     ja .c4
;     neg word [pos_dy]
; .c4:

    push word [pos_y] ; y-offset
    push word [pos_x] ; x-offset
    push WIDTH
    push RECT_WIDTH ; height
    push RECT_HEIGHT ; width
    push 0x04
    call fill

    mov esp, ebp
    ret

jmp $

; stack[1] = color
; stack[2] = width
; stack[3] = height
; stack[4] = bytesPerRow
; stack[5] = x-offset
; stack[6] = y-offset
fill:
    mov si, 0 ; rows-count = 0
.recalc_i
    mov di, stack2(6)      ; di = y-offset
    add di, si             ; di += rows-count
    mov ax, word stack2(5) ; ax = x-offset
    call calc_i            ; ax = i
    mov bx, ax             ; bx = ax = i
    mov dx, 0              ; cols-count = 0
    mov cx, stack2(1)      ; cx = color
.iter:
    mov byte [es:bx], cl   ; draw at i with color 
    inc bx                 ; bx = i => i++
    inc dx                 ; dx = cols-count => cols-count++
    cmp dx, stack2(2)      ; if cols-count < width => draw another
    jb .iter
    
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

pos_dx: dw RECT_INIT_DX 
pos_dy: dw RECT_INIT_DY
pos_x: dw 10
pos_y: dw 199
color: dw 0x00
times 510 - ($ - $$) db 0
dw 0xaa55