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
    original_fileName db "catita.bmp", 0H
    original_readCount dd 0H

    ;Write file variables
    copy_fileHandle dd 0H
    copy_fileName db "catita2.bmp", 0H
    copy_writeCount dd 0H

    ;File Buffers
    read_buffer_size dd 1
    original_fileBuffer db 0H
    bgr_color_buffer byte 3 DUP(0)
    bgr_color_ptr dd OFFSET bgr_color_buffer
    
    ;Filter variables
    ;color_index dd 1
    ;value_to_add dd 0H


    output db "Hello World!", 0ah, 0h
    outputHandle dd 0 ; Variavel para armazenar o handle de saida
    write_count dd 0; Variavel para armazenar caracteres escritos na console

.code   
    ;Clampa cor entre 0 e 255
    ;Nota: modifica o registrador EAX
    _Clamp:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp

        ;eax=param
        xor eax, eax
        mov eax, DWORD PTR[ebp+8]

        ; verifica se tem algum digito diferente de zero nos 8 bits depois de 255
        cmp ah, 0 
        jne _Clamp_Max 
        
        ; como nao ha digito diferente de zero nos primeiros 8 bits mas significantes, o numero eh menor ou igual a 255
        jmp _Clamp_Return

        ;Coloca valor maximo (255) no registrador -----
        _Clamp_Max:
            xor eax, eax
            mov al, 255        

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

        ;Escreve buffer lido no arquivo copia
        invoke WriteFile, copy_fileHandle, addr original_fileBuffer, 54, addr copy_writeCount, NULL ; Escreve buffer_size bytes do arquivo

        ;Epilogo da subrotina --------
        mov esp, ebp
        pop ebp
        ret ; return void


    ;Filtra pixel
    ;params: endereço brg, index da banda para operar, valor a adicionar
    _FilterPixel:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
        sub esp, 12

        ;x = valor a adicionar
        mov eax, DWORD PTR[ebp+8]
        mov DWORD PTR[ebp-4], eax

        ;y = index para operar
        mov eax, DWORD PTR[ebp+12]
        mov DWORD PTR[ebp-8], eax

        ;z = endereço brg
        mov eax, DWORD PTR[ebp+16]
        mov DWORD PTR[ebp-12], eax
        mov ecx, DWORD PTR[ebp-12]

        ;R Value
        mov eax, [ecx][2]
        push eax

        ;G Value
        mov eax, [ecx][1]
        push eax

        ;B Value
        mov eax, [ecx][0]
        push eax


        ;----- Pegando valor no index para clampar -------

        cmp DWORD PTR[ebp-8], 0 
        je _FilterPixel_OnIndexEquals0 ; quando index == 0
        cmp DWORD PTR[ebp-8], 1
        je _FilterPixel_OnIndexEquals1 ; quando index == 1
        cmp DWORD PTR[ebp-8], 2
        je _FilterPixel_OnIndexEquals2 ; quando index == 2

        
        _FilterPixel_OnIndexEquals0:
            mov eax, [ecx][0]
            jmp _FilterPixel_AddValue

        _FilterPixel_OnIndexEquals1:
            mov eax, [ecx][1]
            jmp _FilterPixel_AddValue

        _FilterPixel_OnIndexEquals2:           
            mov eax, [ecx][2]
            jmp _FilterPixel_AddValue

        ;Add value to color and clamp -----------
        _FilterPixel_AddValue:
            xor ah, ah ; ah = 0
            add eax, DWORD PTR[ebp-4]

        _FilterPixel_Clamp:
            ;Clamp color
            push eax
            call _Clamp
            mov edx, eax

        ;----------- Pegando valor no endereco e modificando --------------
        cmp DWORD PTR[ebp-8], 0
        je Filter_Blue
        cmp DWORD PTR[ebp-8], 1 ; Comparando index
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
        ret 12; remove parametros da função

    ;Filtra a imagem
    _FilterImage:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
              
        _FilterImage_Loop:
            invoke ReadFile, original_fileHandle, addr bgr_color_buffer, 3, addr original_readCount, NULL ;Ler banda BGR

            push offset bgr_color_buffer
            push 0 ; index
            push 50 ; valor pra add
            call _FilterPixel
             
            invoke WriteFile, copy_fileHandle, addr bgr_color_buffer, 3, addr copy_writeCount, NULL ; Escreve banda BGR no arquivo         

            ;Verifica EOF ---------
            cmp original_readCount, 0
            je _FilterImage_Return

            jne _FilterImage_Loop

        
        _FilterImage_Return:
            pop ebx
            ;Epilogo da subrotina --------
            mov esp, ebp
            pop ebp
            ret; desaloca parametros
        
start:
    ; Abre arquivo original em depois solicita modo leitura ----------
    invoke CreateFile, addr original_fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov original_fileHandle, eax    

    ; Abre arquivo copia em modo escrever ----------
    invoke CreateFile, addr copy_fileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov copy_fileHandle, eax

    call _CopyFirst54Bytes
    call _FilterImage

    _Exit_Program:
        ; Fecha os arquivos
        invoke CloseHandle, original_fileHandle
        invoke CloseHandle, copy_fileHandle    
        invoke ExitProcess, 0
end start
