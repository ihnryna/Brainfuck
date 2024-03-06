.model tiny
.data

inputFileName db 'Hello.txt', 0
outputFileName db 'TEST.RES', 0
buffer db 255 dup(?) ; Буфер для читання файлу
bytes_read dw ? ; Кількість прочитаних байт


.code
ORG 100h
start:
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
    mov cx, 255 ; читаємо 255 байт
    mov dx, offset buffer
    int 21h
    mov bytes_read, ax ; Збереження кількості прочитаних байт

    ; Закриття файлу
    mov ah, 3Eh
    int 21h

    ; Відкриття/створення файлу для запису
    mov ah, 3Ch
    mov cx, 0
    lea dx, outputFileName
    int 21h
    mov bx, ax ; дескриптор файлу для запису

    ; Запис у файл
    lea dx, buffer
    mov ah, 40h
    mov cx, bytes_read ; кількість прочитаних байт
    int 21h

    ; Закриття файлу
    mov ah, 3Eh
    int 21h

    ; Вихід з програми
    mov ax, 4C00h
    int 21h

end start