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
    mov cl, ds:[80h]   ; at offset 80h length of "args"
write_char:
    mov si, 81h        ; at offest 81h first char of "args"
    add si, cx
    ;mov dl, ds:[si]
    mov byte ptr ds:[si], 0


    ; Відкриття файлу для читання
    mov ah, 3Dh
    xor al, al ; режим читання
    mov dx, 82h
    int 21h
    mov bx, ax ; зберігаємо дескриптор файлу

    lea di, array
    mov cx, 30003
    xor ax, ax
    rep stosb

    ; Читання з файлу
    mov ah, 3Fh
    mov cx, 10000
    mov dx, offset buffer
    int 21h
    mov bytes_read, ax ; Збереження кількості прочитаних байт

    ;cld
    mov SI, offset buffer              ; SI буде вказувати на поточний елемент масиву
    add bytes_read, SI
    mov bx, offset array

array_loop:
    xor cx, cx
    ;MOV al, [buffer + SI]    
    ;lodsb 
    mov al, [SI]

    
    cmp brackets,cl
    jne brackets_loop

    CMP AL, '>'
    jne next0 ;>
    inc bx
    inc bx
next0:

    CMP AL, '<'
    jne next1 ;<
    dec bx
    dec bx
next1:

    CMP AL, '+'
    jne next ;+
    INC [bx]
next:

    CMP AL, '-'
    jne next2 ;-
    dec [bx]
next2:

    cmp AL, '.'
    jne next3 ;.
    cmp [bx], 0Dh
    je array_loop_continue
    cmp [bx], 0Ah
    jne go
    mov dx, 0Dh
    mov ah, 02h
    int 21h
go:
    ; output
    mov dx, [bx]
    mov ah, 02h
    int 21h
    jmp array_loop_continue
next3:

    cmp AL, ','
    jne next4 ;,
    push bx
    and [bx], cx
    mov ah, 3Fh
    lea dx, [bx]
    mov bx, 0h  ; stdin handle
    mov cx, 1   ; 1 byte to read
    int 21h   ;  ax = number of bytes read

    pop bx
    test ax,ax
    jnz array_loop_continue ;noput
    mov [bx], -1
next4:

    cmp AL, '['
    jne next6
    cmp [bx], cx
    jne array_loop_continue_br
    inc brackets
    jmp array_loop_continue
array_loop_continue_br:
    push SI
next6:

    cmp AL, ']'
    jne array_loop_continue
    pop ax
    cmp [bx], cx
    je array_loop_continue
    mov SI, ax
    dec SI

    jmp array_loop_continue

brackets_loop: 
    CMP AL, '['
    jne next5
    inc brackets
next5:
    CMP AL, ']'
    jne array_loop_continue
    dec brackets

array_loop_continue:    
    INC SI                 ; Перемістимо вказівник на наступний елемент масиву
    ;lodsb
    cmp SI, bytes_read
    jle array_loop_link      ; Повторюємо цикл, доки SI не дорівнює bytes_read
    ; Вихід з програми
    ret

array_loop_link:
    jmp array_loop

end start