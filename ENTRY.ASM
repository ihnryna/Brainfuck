.model tiny
.data

inputFileName db 'Hello.txt', 0
outputFileName db 'TEST.RES', 0
buffer db 10000 dup(?) ; Буфер для читання файлу
array db 10000 dup(0) ; 
bytes_read dw ? ; Кількість прочитаних байт

.code
ORG 100h
start:

reading:
    mov ax, cs
    mov ds, ax
    ; Встановлення DTA (Disk Transfer Address)
    mov ah, 1Ah
    mov dx, offset buffer
    int 21h
    ; Відкриття файлу для читання
    mov ah, 3Dh
    mov al, 0 ; режим читання
    lea dx, inputFileName
    int 21h
    mov bx, ax ; зберігаємо дескриптор файлу
    ; Читання з файлу
    mov ah, 3Fh
    mov cx, 10000 ; читаємо 255 байт
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

    JMP default_case

array_loop_continue:    
    INC SI                 ; Перемістимо вказівник на наступний елемент масиву
    cmp SI, bytes_read
    jle array_loop        ; Повторюємо цикл, доки SI не дорівнює bytes_read
    jmp writing

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
    jmp array_loop_continue

case_6:
    mov dl, [array + bx]
    mov ah, 02h
    int 21h
    jmp array_loop_continue

case_open:
    jmp array_loop_continue

case_close:
    jmp array_loop_continue

default_case:
    jmp array_loop_continue

writing:
    ; Відкриття/створення файлу для запису
    mov ah, 3Ch
    mov cx, 0
    lea dx, outputFileName
    int 21h
    mov bx, ax ; дескриптор файлу для запису
    ; Запис у файл


    mov bx, 0
writing_loop:
    mov dl, [array + bx]
    mov ah, 02h
    int 21h
    inc bx
    ;inc bx
    cmp bx, 16
    jle writing_loop
    ;lea dx, array
    ;mov ah, 40h
    ;mov cx, bytes_read ; кількість прочитаних байт
    ;int 21h
    ; Закриття файлу
    mov ah, 3Eh
    int 21h


ending:
    ; Вихід з програми
    mov ax, 4C00h
    int 21h

end start