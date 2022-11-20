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
    ;Read file variables
    original_fileHandle dd 0H
    original_fileName db "catita.BMP", 0H
    original_readCount dd 0H

    ;Write file variables
    copy_fileHandle dd 0H
    copy_fileName db "catita2.BMP", 0H
    copy_writeCount dd 0H

    ;File Buffers
    read_buffer_size dd 1
    original_fileBuffer db 0H
    b_color_buffer dd 0H
    g_color_buffer dd 0H
    r_color_buffer dd 0H

    ;Filter variables
    color_index dd 0
    value_to_add dd 0

.code   
    ;Clampa cor entre 0 e 255
    _Clamp:
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
            ret 4; desaloca parametro
            

    ;Copia primeiros 54 bytes da imagem
    _CopyFirst54Bytes:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
        
        ;Ler original
        invoke ReadFile, original_fileHandle, addr original_fileBuffer, 54, addr original_readCount, NULL 

        ;Escreve buffer lido no arquivo cópia
        invoke WriteFile, copy_fileHandle, addr original_fileBuffer, 54, addr copy_writeCount, NULL ; Escreve buffer_size bytes do arquivo

        ;Epilogo da subrotina --------
        mov esp, ebp
        pop ebp
        ret ; retorn void

    ;Filtra a imagem
    _FilterImage:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
        
        _FilterImage_Loop:
            invoke ReadFile, original_fileHandle, addr b_color_buffer, 1, addr original_readCount, NULL ;Ler banda B
            invoke ReadFile, original_fileHandle, addr g_color_buffer, 1, addr original_readCount, NULL ;Ler banda G
            invoke ReadFile, original_fileHandle, addr r_color_buffer, 1, addr original_readCount, NULL ;Ler banda R  

            jmp _FilterImage_Loop_WriteBGR

            cmp color_index, 0
            je _FilterImage_Loop_AddToB
            cmp color_index, 1
            je _FilterImage_Loop_AddToG
            cmp color_index, 2
            je _FilterImage_Loop_AddToR

            _FilterImage_Loop_AddToB:
                jmp _FilterImage_Loop_WriteBGR
                
            _FilterImage_Loop_AddToG:
                jmp _FilterImage_Loop_WriteBGR

            _FilterImage_Loop_AddToR:
                jmp _FilterImage_Loop_WriteBGR
                
            _FilterImage_Loop_WriteBGR:
                invoke WriteFile, copy_fileHandle, addr b_color_buffer, 1, addr copy_writeCount, NULL ; Escreve banda B no arquivo 
                invoke WriteFile, copy_fileHandle, addr g_color_buffer, 1, addr copy_writeCount, NULL ; Escreve banda G no arquivo 
                invoke WriteFile, copy_fileHandle, addr r_color_buffer, 1, addr copy_writeCount, NULL ; Escreve banda R no arquivo                  

            ;Verifica EOF ---------
            cmp original_readCount, 0
            je _FilterImage_Return

            jne _FilterImage_Loop

        ;Epilogo da subrotina --------
        _FilterImage_Return:
            mov esp, ebp
            pop ebp
            ret ; retorn void
        
start:
    ; Abre arquivo original em depois solicita modo leitura ----------
    invoke CreateFile, addr original_fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov original_fileHandle, eax    

    ; Abre arquivo cópia em modo escrever ----------
    invoke CreateFile, addr copy_fileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov copy_fileHandle, eax

    call _CopyFirst54Bytes
    call _FilterImage
        
    _Exit_Program:
        ; Fecha os arquivos
        invoke CloseHandle, original_fileHandle
        invoke CloseHandle, copy_fileHandle
end start
