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
    original_fileName db "a.txt", 0H
    original_readCount dd 0
    
    copy_fileHandle dd 0H
    copy_fileName db "b.txt", 0H
    copy_writeCount dd 0

    read_buffer_size dd 2H
    original_fileBuffer db 3 dup(0H)

    outputHandle dd 0
    console_count dd 0
    tamanho_string dd 0

    hexa_string_buffer db 2 dup(0H)
    test_buffer dd 0H
.code

    _StrToDword:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp

        ;Epilogo da subrotina --------   
        _Clamp_Return:
            mov esp, ebp
            pop ebp
            ret 4; desaloca parametro

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

        ;PRINT -------------------
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov outputHandle, eax
        
        invoke StrLen, addr original_fileBuffer
        mov tamanho_string, eax
        
        invoke WriteConsole, outputHandle, addr original_fileBuffer, tamanho_string, addr console_count, NULL
        ;---------------------

        ;SOMA ----------     
        invoke atodw, addr original_fileBuffer ; salva em eax a conversao 
        ;add eax, 5 ; 50
        invoke dw2hex, eax, addr original_fileBuffer
        ;invoke dwtoa, eax, addr original_fileBuffer
        invoke dwtoa, eax, addr hexa_string_buffer
        ;---------------

        ;PRINT -------------------
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov outputHandle, eax
        
        invoke StrLen, addr test_buffer
        mov tamanho_string, eax

        mov eax, 255
        mov eax, uhex$(eax)
        mov test_buffer, eax
        printf("%s", AH)

        ;invoke StrLen, addr test_buffer
        ;mov tamanho_string, eax
        
        ;invoke WriteConsole, outputHandle, addr test_buffer, tamanho_string, addr console_count, NULL
        ;---------------------
             
        ;Escreve buffer lido no arquivo cópia
        invoke WriteFile, copy_fileHandle, addr test_buffer, 2, addr copy_writeCount, NULL ; Escreve buffer_size bytes do arquivo 

        jne _Copy_Loop
        
    _Exit_Program:
        ; Fecha os arquivos
        invoke CloseHandle, original_fileHandle
        invoke CloseHandle, copy_fileHandle
end start
