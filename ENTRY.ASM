.model tiny
.data
R equ 21h
array dw 10000 dup(?) 
buffer db 10000 dup(?) ; Буфер для читання файлу
bytes_read dw ? ; Кількість прочитаних байт
brackets db ?


.code
ORG 100h
start:

reading:
    ; ds = PSP
    ; copy param
    xor ch,ch
    mov cl, ds:[80h]   ; at offset 80h length of "args"
    xor bx, bx
write_char:
    test cl, cl
    jz write_end
    mov si, 81h        ; at offest 81h first char of "args"
    add si, cx
    mov dl, ds:[si]
    cmp dl, 0Dh
    jne noputzero
    mov byte ptr ds:[si], 0
noputzero:
    dec cl
    jmp short write_char

write_end:
    ; Відкриття файлу для читання
    mov ah, 3Dh
    xor al, al ; режим читання
    mov dx, 82h
    int R
    mov bx, ax ; зберігаємо дескриптор файлу

    lea di, array
    mov cx, 30003
    xor ax, ax
    rep stosb

    ; Читання з файлу
    mov ah, 3Fh
    mov cx, 10000 ; читаємо 10000 байт
    mov dx, offset buffer
    int R
    mov bytes_read, ax ; Збереження кількості прочитаних байт
    ; Закриття файлу
    ;mov ah, 3Eh
    ;int 21h

    ;cld
    mov SI, offset buffer              ; SI буде вказувати на поточний елемент масиву
    add bytes_read, SI
    mov bx, offset array
    ;xor bx, bx

array_loop:
    ;MOV al, [buffer + SI]    
    ;lodsb 
    mov al, [SI]

    CMP AL, '>'
    je short case_1 ;>

    CMP AL, '<'
    je short case_2 ;<

    CMP AL, '+'
    je short case_3 ;+

    CMP AL, '-'
    je short case_4 ;-

    cmp al, '.'
    je short case_5 ;.

    cmp al, ','
    je short case_6 ;,

    cmp al, '['
    je case_open

    cmp al, ']'
    je case_close_link

array_loop_continue:    
    INC SI                 ; Перемістимо вказівник на наступний елемент масиву
    ;lodsb
    cmp SI, bytes_read
    jle array_loop        ; Повторюємо цикл, доки SI не дорівнює bytes_read
    jmp ending

case_1:
    inc bx
    inc bx
    jmp short array_loop_continue

case_2:
    dec bx
    dec bx
    jmp short array_loop_continue

case_3:
    MOV ax, [bx]
    INC ax
    MOV [bx], ax
    jmp short array_loop_continue

case_4:
    MOV ax, [bx]
    dec ax
    MOV [bx], ax
    jmp short array_loop_continue

case_5:
    mov dx, [bx]
    cmp dx, 0Dh
    je array_loop_continue
    cmp dx, 0Ah
    jne go
    mov dx, 0Dh
    mov ah, 02h
    int R
go:
    ; output
    mov dx, [bx]
    mov ah, 02h
    int R
    jmp array_loop_continue

case_close_link:
    jmp case_close

case_6:
    push bx
    and [bx], 0
    mov ah, 3Fh
    lea dx, [bx]
    mov bx, 0h  ; stdin handle
    mov cx, 1   ; 1 byte to read
    int R   ;  ax = number of bytes read

    pop bx
    cmp ax, 0
    jne noput
    mov [bx], -1
noput:
    jmp array_loop_continue

case_open:
    MOV ax, [bx]
    cmp ax, 0
    jne array_loop_continue
    inc brackets
brackets_loop:
    cmp brackets,0
    je array_loop_continue
    inc SI
    MOV al, [SI]    
    CMP AL, '['
    je inc_br
    CMP AL, ']'
    jne short brackets_loop
    dec brackets
    jmp short brackets_loop

case_close:
    MOV ax, [bx]
    cmp ax, 0
    je cont2
    MOV al, [SI]  
    CMP AL, ']'
    jne brackets_loop2
    inc brackets
brackets_loop2:
    cmp brackets, 0
    je cont3
    dec SI
    MOV al, [SI] 
    CMP AL, '['
    je dec_br2
    CMP AL, ']'
    jne short brackets_loop2
    inc brackets
    jmp short brackets_loop2


inc_br:
    inc brackets
    jmp brackets_loop

cont2:
    jmp array_loop_continue
cont3:
    dec SI
    jmp array_loop_continue

dec_br2:
    dec brackets
    jmp brackets_loop2

ending:
    ; Вихід з програми
    mov ax, 4C00h
    int R

end start