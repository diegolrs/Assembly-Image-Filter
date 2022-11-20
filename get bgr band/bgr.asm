.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib
include \masm32\macros\macros.asm

.data
    original_fileHandle dd 0H
    original_fileName db "catita.BMP", 0H
    original_readCount dd 0
    
    copy_fileHandle dd 0H
    copy_fileName db "catita2.BMP", 0H
    copy_writeCount dd 0

    read_buffer_size dd 3
    original_fileBuffer db 3 dup(0)

.code

    _Copia_Primeiros_54_Bytes:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
   
        ;eax=param
        mov eax, DWORD PTR[ebp+8]

        _Clamp_Compara:
            cmp eax, 0H
            jl _Clamp_Menor
            cmp eax, 0FFH ;255
            jg _Clamp_Maior
            jmp _Clamp_Return

        _Clamp_Menor:
            xor eax, eax ;eax = 0
            jmp _Clamp_Compara

        _Clamp_Maior:
            mov eax, 255
            jmp _Clamp_Compara

        ;Epilogo da subrotina --------   
        _Clamp_Return:
            mov esp, ebp
            pop ebp
            ret ; desaloca parametro
start:
    ; Abre arquivo original em depois solicita modo leitura
    invoke CreateFile, addr original_fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov original_fileHandle, eax    

    ; Abre arquivo cópia em modo escrever
    invoke CreateFile, addr copy_fileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov copy_fileHandle, eax

    
    _Copy_Loop:
        ;Ler original
        invoke ReadFile, original_fileHandle, addr original_fileBuffer, read_buffer_size, addr original_readCount, NULL 

        ;Verifica EOF
        cmp original_readCount, 0
        je _Exit_Program
        
        ;Escreve buffer lido no arquivo cópia
        invoke WriteFile, copy_fileHandle, addr original_fileBuffer + 0, 1, addr copy_writeCount, NULL ; Escreve buffer_size bytes do arquivo
        invoke WriteFile, copy_fileHandle, addr original_fileBuffer + 1, 1, addr copy_writeCount, NULL ; Escreve buffer_size bytes do arquivo
        invoke WriteFile, copy_fileHandle, addr original_fileBuffer + 2, 1, addr copy_writeCount, NULL ; Escreve buffer_size bytes do arquivo

        jne _Copy_Loop
        
    _Exit_Program:
        ; Fecha os arquivos
        invoke CloseHandle, original_fileHandle
        invoke CloseHandle, copy_fileHandle
end start
