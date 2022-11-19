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
    fileHandle dd 0H
    fileName db "out.txt", 0H
    fileBuffer db "Hello world", 0H
    writeCount dd 0

.code
start:
    _Read_File: ; Abre arquivo em modo escrita
    invoke CreateFile, addr fileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov fileHandle, eax

    _Write_File: ;Escreve buffer no arquivo
    invoke WriteFile, fileHandle, addr fileBuffer, 12, addr writeCount, NULL ; Escreve 10 bytes do arquivo
    printf("Status: %d", EAX)

    _Close_File: ; Fecha o arquivo
    invoke CloseHandle, fileHandle
end start
