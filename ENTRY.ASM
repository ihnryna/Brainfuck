.model tiny
.data

inputFileName db 'TEST1.B', 0
buffer db 10000 dup(?) ; Буфер для читання файлу
array db 10000 dup(0) ;
msg db ? ; 
bytes_read dw ? ; Кількість прочитаних байт
file_handler dw ?
brackets db 0
filename db 7 dup(?)
myfilename db 8 dup(?)

.code
ORG 100h
start:

reading:
    ; ds = PSP
    ; copy param
    xor ch,ch
    mov cl, ds:[80h]   ; at offset 80h length of "args"
    mov bx, 7
write_char:
    test cl, cl
    jz write_end
    mov si, 81h        ; at offest 81h first char of "args"
    add si, cx
    ;mov ah, 02h
    mov dl, ds:[si]
    mov [filename+bx], dl
    dec bx
    ;int 21h
    dec cl
    jmp write_char
write_end:

    mov bx, 0
writing_loop:
    mov dl, [filename + bx]
    mov [myfilename+bx], dl
    inc bx
    cmp bx, 6
    jle writing_loop
    mov dl, 0
    mov [myfilename+bx], dl


    mov ax, cs
    mov ds, ax
    ; Встановлення DTA (Disk Transfer Address)
    mov ah, 1Ah
    mov dx, offset buffer
    int 21h
    ; Відкриття файлу для читання
    mov ah, 3Dh
    mov al, 0 ; режим читання
    lea dx, myfilename
    int 21h
    mov bx, ax ; зберігаємо дескриптор файлу
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
    je case_close

    ;JMP default_case

array_loop_continue:    
    INC SI                 ; Перемістимо вказівник на наступний елемент масиву
    cmp SI, bytes_read
    jle array_loop        ; Повторюємо цикл, доки SI не дорівнює bytes_read
    jmp ending

case_1:
    ;MOV array[12], 66
    inc bx
    jmp array_loop_continue

case_2:
    dec bx
    jmp array_loop_continue

case_3:
    push ax
    MOV al, array[bx]
    INC al
    MOV array[bx], al
    pop ax
    jmp array_loop_continue

case_4:
    push ax
    MOV al, array[bx]
    dec al
    MOV array[bx], al
    pop ax
    jmp array_loop_continue

case_5:
    push ax

    ; output
    mov dl, [array + bx]
    mov ah, 02h
    int 21h

    pop ax

    jmp array_loop_continue

case_6:
    push ax
    push bx
    mov ah, 3Fh
    mov dl, [array+bx]   ; read to ds:dx 
    mov bx, 0h  ; stdin handle
    mov cx, 1   ; 1 byte to read
    int 21h
    pop bx
    pop ax
    jmp array_loop_continue

case_open:
    push ax
    MOV al, array[bx]
    cmp al, 0
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
    MOV al, array[bx]
    cmp al, 0
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

default_case:
    jmp array_loop_continue

ending:

    ; Вихід з програми
    mov ax, 4C00h
    int 21h

end start