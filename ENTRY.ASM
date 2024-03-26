.model tiny
.data
array dw 10000 dup(?) 
buffer db 10000 dup(?) ; Буфер для читання файлу

.code
ORG 100h
start:

reading:
    ; ds = PSP
    ; copy param
    mov cl, ds:[80h]   ; at offset 80h length of "args"
    mov si, 81h        ; at offest 81h first char of "args"
    add si, cx
    mov byte ptr ds:[si], 0
    ; Відкриття файлу для читання
    mov ah, 3Dh
    mov dx, 82h
    int 21h
    mov bx, ax ; зберігаємо дескриптор файлу

    lea di, array
    mov cx, 30000
    xor ax, ax
    rep stosb

    ; Читання з файлу
    mov ah, 3Fh
    mov cx, 10000
    mov dx, offset buffer
    int 21h

    ;cld
    mov SI, dx             ; SI буде вказувати на поточний елемент масиву
    mov bx, offset array

    xor cx, cx
    xor di, di

array_loop:
    lodsb 
    ;mov al, [SI]
    
    cmp cx, di
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
    je next3
    mov ah, 02h
    cmp [bx], 0Ah
    jne go
    mov dx, 0Dh
    int 21h
go:
    ; output
    mov dx, [bx]
    int 21h
    jmp array_loop_continue
next3:

    cmp AL, ','
    jne next4 ;,
    push bx
    and [bx], di
    mov ah, 3Fh
    lea dx, [bx]
    mov bx, di  ; stdin handle
    inc cx    ;mov cx, 1   ; 1 byte to read
    int 21h   ;  ax = number of bytes read
    dec cx
    pop bx
    test ax,ax
    jnz array_loop_continue ;noput
    mov [bx], -1
next4:

    cmp AL, '['
    jne next6
    push SI
    cmp [bx], di
    jne array_loop_continue
    inc cx
    ;jmp array_loop_continue
;array_loop_continue_br:
next6:

    cmp AL, ']'
    jne array_loop_continue
    pop ax
    cmp [bx], di
    je array_loop_continue
    mov SI, ax
    dec SI


array_loop_continue:    
    ;INC SI
    cmp [SI], di
    jne array_loop      
    ; Вихід з програми
    ret

brackets_loop: 
    CMP AL, '['
    jne next5
    push SI
    inc cx
next5:
    CMP AL, ']'
    jne array_loop_continue
    pop ax
    dec cx
    jmp array_loop_continue

end start ; not the mosquito again!!!!🦟🦟🦟🦟🦟🦟🦟🦟 bzzzzzzzzzzz