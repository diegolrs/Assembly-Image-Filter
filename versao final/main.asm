; Aluno: Diego Luis Reis da Silva
; Matricula: 20210114719

.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

;Bibliotecas criadas 
include clamp.inc
include console-messages.inc
include myIO.inc

.data
    ;Read file variables
    original_fileHandle dd 0H
    original_readCount dd 0H

    ;Write file variables
    copy_fileHandle dd 0H
    copy_writeCount dd 0H

    ;File Buffers
    read_buffer_size dd 1H
    original_fileBuffer db 54 dup(0)
    bgr_color_buffer byte 3 DUP(0)
    
    ;Core variables
    color_index dd 1H ; index para alterar
    value_to_add dd 0H ; valor para adicionar
    copy_name db 50 dup(0) ; nome do novo arquivo copia
    originalfile_name db 50 dup(0) ; nome do arquivo original

.code   
    ;Copia primeiros 54 bytes da imagem original para a copia
    _CopyFirst54Bytes:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
        
        ;Ler original
        invoke ReadFile, original_fileHandle, addr original_fileBuffer, 54, addr original_readCount, NULL 

        ;Escreve buffer lido no arquivo copia
        invoke WriteFile, copy_fileHandle, addr original_fileBuffer, 54, addr copy_writeCount, NULL ; Escreve os 54 bytes do arquivo

        ;Epilogo da subrotina --------
        mov esp, ebp
        pop ebp
        ret


    ;Filtra pixel adicionando valor a uma das bandas de cor
    ;params: endereço do array BGR, index da banda para operar, valor a adicionar
    ;Nota: modifica os registradores EAX, ECX e EDX
    _FilterPixel:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
        sub esp, 12

        ;valor a adicionar
        mov eax, DWORD PTR[ebp+8]
        mov DWORD PTR[ebp-4], eax

        ;index para operar
        mov eax, DWORD PTR[ebp+12]
        mov DWORD PTR[ebp-8], eax

        ;endereço do array BGR
        mov eax, DWORD PTR[ebp+16]
        mov DWORD PTR[ebp-12], eax
        mov ecx, DWORD PTR[ebp-12]

        ;Banda R
        mov eax, [ecx][2]
        push eax

        ;Banda G
        mov eax, [ecx][1]
        push eax

        ;Banda B
        mov eax, [ecx][0]
        push eax


        ;----- Pegando valor na banda (index) desejada -------
        cmp DWORD PTR[ebp-8], 0 
        je _FilterPixel_AddValue ; quando index == 0, nao precisa configurar nada, pois valor do index zero ja esta em eax
        cmp DWORD PTR[ebp-8], 1
        je _FilterPixel_OnIndexEquals1 ; quando index == 1
        cmp DWORD PTR[ebp-8], 2
        je _FilterPixel_OnIndexEquals2 ; quando index == 2

        _FilterPixel_OnIndexEquals1:
            mov eax, [ecx][1]
            jmp _FilterPixel_AddValue

        _FilterPixel_OnIndexEquals2:           
            mov eax, [ecx][2]
            jmp _FilterPixel_AddValue

        ;Soma valor na banda escolhida
        _FilterPixel_AddValue:
            xor ah, ah ; ah = 0
            add eax, DWORD PTR[ebp-4]

        ;Clampa valor somado no intervalo [0, 255] -----------
        _FilterPixel_Clamp:
            push eax
            call _Clamp
            mov edx, eax

        ;----------- Filtrando imagem adicionando valor na banda de cor escolhida --------------
        cmp DWORD PTR[ebp-8], 0
        je Filter_Blue
        cmp DWORD PTR[ebp-8], 1 ; 
        je Filter_Green
        cmp DWORD PTR[ebp-8], 2 ; 
        jmp Filter_Red

        Filter_Blue:
            pop eax
            mov DWORD PTR[ecx], edx ; B
            pop eax
            mov DWORD PTR[ecx+1], eax ; G
            pop eax
            mov DWORD PTR[ecx+2], eax ; R
            jmp _FilterPixel_Return
        Filter_Green:
            pop eax
            mov DWORD PTR[ecx], eax ; B
            pop eax
            mov DWORD PTR[ecx+1], edx ; G
            pop eax
            mov DWORD PTR[ecx+2], eax ; R
            jmp _FilterPixel_Return
        Filter_Red:
            pop eax
            mov DWORD PTR[ecx], eax ; B
            pop eax
            mov DWORD PTR[ecx+1], eax ; G
            pop eax
            mov DWORD PTR[ecx+2], edx ; R
            jmp _FilterPixel_Return
        ;-------------------------------------------------------------------
        
        _FilterPixel_Return:
            ;Epilogo da subrotina --------
            mov esp, ebp
            pop ebp
            ret 12; remove parametros da funcao

    ;Filtra a imagem, aplicando a logica do filtro em cada pixel
    _FilterImage:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
        sub esp, 12

        ;valor a adicionar
        mov eax, DWORD PTR[ebp+8]
        mov DWORD PTR[ebp-4], eax

        ;index para operar
        mov eax, DWORD PTR[ebp+12]
        mov DWORD PTR[ebp-8], eax

        ;endereço brg
        mov eax, DWORD PTR[ebp+16]
        mov DWORD PTR[ebp-12], eax
              
        _FilterImage_Loop:
            ;Le pixel BGR
            invoke ReadFile, original_fileHandle, addr bgr_color_buffer, 3, addr original_readCount, NULL

            ;Filtra pixel lido
            push DWORD PTR[ebp-12] ; endereco array BGR
            push DWORD PTR[ebp-8] ; index
            push DWORD PTR[ebp-4] ; valor pra add
            call _FilterPixel

            ;Escreve pixel BGR no arquivo 
            invoke WriteFile, copy_fileHandle, addr bgr_color_buffer, 3, addr copy_writeCount, NULL        

            ;Verifica EOF ---------
            cmp original_readCount, 0
            je _FilterImage_Return
            jne _FilterImage_Loop
        
        _FilterImage_Return:
            pop ebx
            ;Epilogo da subrotina --------
            mov esp, ebp
            pop ebp
            ret 12; desaloca parametros

    ;Le os dados de entrada para aplicar no programa
    _ReadInputs:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
        
        ;Solicita nome do arquivo original -----------------
            ;---- Printa mensagem ----
            push offset CONSOLE_MSG_NOME_ARQUIVO_ORIGINAL
            call _MyIO_LogMessage

            ;---- Aguarda e trata entrada ----
            push sizeof originalfile_name
            push offset originalfile_name
            call _MyIO_ReadString
            
        ;Solicita nome do arquivo copia -----------------
            ;---- Printa mensagem ----
            push offset CONSOLE_MSG_NOME_ARQUIVO_COPIA
            call _MyIO_LogMessage

            ;---- Aguarda e trata entrada ----
            push sizeof copy_name
            push offset copy_name
            call _MyIO_ReadString

        ;Solicitar o index da cor ------------------
            ;---- Printa mensagem ----
            push offset CONSOLE_MSG_INDEX_COR
            call _MyIO_LogMessage
    
            ;---- Aguarda e trata entrada ----
            call _MyIO_ReadInteger
            mov color_index, eax
    
        ;Solicitar valor para adicionar ------------
            ;---- Printa mensagem ----
            push offset CONSOLE_MSG_QTD_ADD
            call _MyIO_LogMessage
    
            ;---- Aguarda e trata entrada ----
            call _MyIO_ReadInteger
            mov value_to_add, eax

        ;Epilogo da subrotina --------
        mov esp, ebp
        pop ebp
        ret; desaloca parametros

        
start:
    call _MyIO_Setup ; Setup dos handler de entrada e saida do console
    call _ReadInputs ; Recebe e trata as entradas, salvando-as na memoria

    ; Abre foto original e depois solicita modo leitura ----------
    invoke CreateFile, addr originalfile_name, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov original_fileHandle, eax   

    ; Abre foto copia e solicita modo escrever ----------
    invoke CreateFile, addr copy_name, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov copy_fileHandle, eax

    ;Copia primeiros 54 bytes da imagem
    call _CopyFirst54Bytes

    ;Filtra os bytes de cor BGR imagem
    push offset bgr_color_buffer
    push color_index
    push value_to_add  
    call _FilterImage
    
    ;Fecha os arquivos e encerra o programa
    invoke CloseHandle, original_fileHandle
    invoke CloseHandle, copy_fileHandle    
    invoke ExitProcess, 0
end start
