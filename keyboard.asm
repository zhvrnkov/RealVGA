[ORG 0x7C00]
[BITS 16]

%macro read_key_press 0
    mov ah, 0x01
    int 0x16
%endmacro

xor ax, ax
mov es, ax
cli
mov dword [es:4 * 9], keyboardHandler
mov [es:4 * 9 + 2], cs
sti

jmp $

keyboardHandler:
    pusha 

    in al, 0x60
    ; test al, 0x80
    ; jnz .end
    and al, ~0x80
    call print_int
    mov ah, 0x0e
    mov al, 10 
    int 0x10
.end:
    mov al, 0x61
    out 20h, al
    popa 
    iret
    ; in al, 0x

print_int:
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
  ret

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

times 510 - ($ - $$) db 0
dw 0xaa55