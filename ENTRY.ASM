.model tiny
.data
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
    mov bx, 0
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
    jmp write_char

;myloop:
 ;   mov byte ptr [di], 0
  ;  inc di
   ; loop myloop

write_end:
    ; Відкриття файлу для читання
    mov ah, 3Dh
    mov al, 0 ; режим читання
    mov dx, 82h
    ;inc dx
    int 21h
    mov bx, ax ; зберігаємо дескриптор файлу

    lea di, array
    mov cx, 30003
    xor ax, ax
    rep stosb

    ; Читання з файлу
    mov ah, 3Fh
    mov cx, 10000 ; читаємо 10000 байт
    mov dx, offset buffer
    int 21h
    mov bytes_read, ax ; Збереження кількості прочитаних байт
    ; Закриття файлу
    mov ah, 3Eh
    int 21h

    MOV SI, 0              ; SI буде вказувати на поточний елемент масиву
    mov bx, 0

array_loop:
    MOV al, [buffer + SI]     
    CMP AL, '>'
    je case_1 ;>

    CMP AL, '<'
    je case_2 ;<

    CMP AL, '+'
    je case_3 ;+

    CMP AL, '-'
    je case_4 ;-

    cmp al, '.'
    je case_5 ;.

    cmp al, ','
    je case_6 ;,

    cmp al, '['
    je case_open

    cmp al, ']'
    je case_close_link

array_loop_continue:    
    INC SI                 ; Перемістимо вказівник на наступний елемент масиву
    cmp SI, bytes_read
    jle array_loop        ; Повторюємо цикл, доки SI не дорівнює bytes_read
    jmp ending

case_1:
    inc bx
    inc bx
    jmp array_loop_continue

case_2:
    dec bx
    dec bx
    jmp array_loop_continue

case_3:
    push ax
    MOV ax, array[bx]
    INC ax
    MOV array[bx], ax
    pop ax
    jmp array_loop_continue

case_4:
    push ax
    MOV ax, array[bx]
    dec ax
    MOV array[bx], ax
    pop ax
    jmp array_loop_continue

case_5:
    push ax
    mov dx, [array + bx]
    cmp dx, 0Dh
    je array_loop_continue
    cmp dx, 0Ah
    jne go
    mov dx, 0Dh
    mov ah, 02h
    int 21h
go:
    ; output
    mov dx, [array + bx]
    mov ah, 02h
    int 21h
    pop ax
    jmp array_loop_continue

case_close_link:
    jmp case_close

case_6:
    push ax
    push bx
    and [array+bx], 0
    mov ah, 3Fh
    lea dx, [array+bx]   ; read to ds:dx 
    mov bx, 0h  ; stdin handle
    mov cx, 1   ; 1 byte to read
    int 21h   ;  ax = number of bytes read

    pop bx
    cmp ax, 0
    jne noput
    mov [array+bx], -1
noput:
    pop ax
    jmp array_loop_continue

case_open:
    push ax
    MOV ax, array[bx]
    cmp ax, 0
    jne cont
    inc brackets
brackets_loop:
    cmp brackets, 0
    je cont
    inc SI
    MOV al, [buffer + SI]     
    CMP AL, '['
    je inc_br
    CMP AL, ']'
    je dec_br
    jmp brackets_loop

case_close:
    push ax
    MOV ax, array[bx]
    cmp ax, 0
    je cont2
    MOV al, [buffer + SI]     
    CMP AL, ']'
    jne brackets_loop2
    inc brackets
brackets_loop2:
    cmp brackets, 0
    je cont3
    dec SI
    MOV al, [buffer + SI]     
    CMP AL, '['
    je dec_br2
    CMP AL, ']'
    je inc_br2
    jmp brackets_loop2


cont:
    pop ax
    jmp array_loop_continue

inc_br:
    inc brackets
    jmp brackets_loop

dec_br:
    dec brackets
    jmp brackets_loop


cont2:
    pop ax
    jmp array_loop_continue
cont3:
    pop ax
    dec SI
    jmp array_loop_continue

inc_br2:
    inc brackets
    jmp brackets_loop2

dec_br2:
    dec brackets
    jmp brackets_loop2

ending:
    ; Вихід з програми
    mov ax, 4C00h
    int 21h

end start