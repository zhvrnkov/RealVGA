[ORG 0x7C00]	;Origin, tell the assembler that where the code will
[BITS 16]

mov cx, 0x31
push cx
mov cx, 0x32
push cx
mov ax, word ss:[esp]
call print_char
push 0x33
mov ax, word ss:[esp]
call print_char

mov byte [i], 0x35
mov ax, word [i]
call print_char

jmp $

jmp print_int

print_hello:
  mov ah, 0x0e
  mov bx, 0
  mov edx, hello
  mov al, [edx]
  int 0x10
  inc edx
  inc bx
  cmp bx, helloLen
  jl print_hello

; ax = input
print_int:
  mov ax, 27

  mov si, ax
  call count_digits ; cx = digits number
  dec cx
  mov ax, 10
  call pow_int

  mov ax, si

  mov si, 10
print_int_loop:
  xor dx, dx
  div cx
  call print_digit
  mov ax, dx

  mov bx, dx ; save remainder
  xor dx, dx
  mov ax, cx
  div si
  mov cx, ax
  mov ax, bx

  cmp cx, 0
  ja print_int_loop



;   xor dx, dx
; print_digit:


  ; xor dx, dx
  ; mov ax, 1234
  ; mov bx, 1000
  ; div bx ; ax = quotient dx = remainder

  ; mov bx, ax ; bx = quotient
  ; add bx, 0x30
  ; mov ah, 0x0e
  ; mov al, bl
  ; int 0x10

  ; mov ax, dx
  ; xor dx, dx
  ; mov bx, 100
  ; div bx

  ; mov bx, ax ; bx = quotient
  ; add bx, 0x30
  ; mov ah, 0x0e
  ; mov al, bl
  ; int 0x10

jmp $

; ax = input
; cx = output
count_digits:
  mov cx, 0

  cd_loop:
    inc cx
    xor dx, dx
    mov bx, 10
    div bx
    cmp ax, 0
    jne cd_loop

    ret

; ax = input
; cx = power
; cx = output
pow_int:
  mov bx, ax
  mov ax, 1
  pow_int_loop:
    jcxz pow_int_done
    mul bx
    loop pow_int_loop
  pow_int_done:
    mov cx, ax
    ret


; ax = input
print_digit:
  mov bx, ax
  xor ax, ax
  add bx, 0x30
  mov ah, 0x0e
  mov al, bl
  int 0x10
  ret

; ax = input
print_char:
  mov bx, ax
  xor ax, ax
  mov ah, 0x0e
  mov al, bl
  int 0x10
  ret

i: db 0
ten: db 10
hello: db 'Hello, world!'
helloLen: equ $-hello

times 510 - ($ - $$) db 0
dw 0xaa55
