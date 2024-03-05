.model tiny

.DATA
    FileName    DB  "TEST.RES",0
    Buffer      DB  "Hello, world!",0
.code   
ORG 0100h
start:
    ; Open the file
        MOV AH, 3Ch      ; Function 3Ch - Create or open file
        MOV CX, 0        ; Access mode (0 = Read/Write)
        LEA DX, FileName ; Load the address of the file name
        INT 21h          ; Call DOS interrupt

        ; Store the file handle in BX
        MOV BX, AX

        ; Write to the file
        MOV AH, 40h      ; Function 40h - Write to file
        MOV CX, 14       ; Number of bytes to write
        LEA DX, Buffer   ; Load the address of the buffer
        INT 21h          ; Call DOS interrupt

        ; Close the file
        MOV AH, 3Eh      ; Function 3Eh - Close file
        MOV BX, AX       ; Move the file handle to BX
        INT 21h          ; Call DOS interrupt

        ; Exit the program
        MOV AH, 4Ch      ; Function 4Ch - Exit program
        INT 21h          ; Call DOS interrupt


end start

