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
    bgr_color_buffer byte 3 DUP(0)
    bgr_color_ptr dd OFFSET bgr_color_buffer
    
    ;Filter variables
    color_index dd 0H
    value_to_add dd 0H

.code   
    ;Clampa cor entre 0 e 255
    ;Nota: modifica o registrador EAX
    _Clamp:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
   
        ;eax=param
        mov eax, DWORD PTR[ebp+8]

        _Clamp_Compara:
            cmp al, 0H
            jb _Clamp_Menor
            cmp al, 0FFH ; 255
            ja _Clamp_Maior
            jmp _Clamp_Return

        _Clamp_Menor:
            xor eax, eax ;eax = 0
            jmp _Clamp_Return

        _Clamp_Maior:
            mov eax, 0FFH ; 255

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
        ret; 4; retorn void

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
        mov ecx, eax

        ;z = endereço brg
        mov eax, DWORD PTR[ebp+16]
        ;mov eax, [eax]
        mov DWORD PTR[ebp-12], eax

        ;TODO: CONSERTAR ESSA ABA *******

        ;----------- Pegando valor no endereco e modificando --------------
        mov eax, DWORD PTR[ebp+16] ; x = param[ecx]
        mov eax, [eax] ; resgatando valor no endereço

        invoke atodw, DWORD PTR[ebp-12] ; salva em eax a conversao 
        add eax, 0 ; soma com valor constante
        invoke dwtoa, eax, DWORD PTR[ebp-12]


        mov ebx, [ebp+8] ; ponteiro de pointeiro
        mov DWORD PTR[ebx], eax ; colocando valor indiretamente
        ;-------------------------------------------------------------------

        ;add eax, 50
        ;mov eax, DWORD PTR[ebp+16]

        ;mov ecx, DWORD PTR[ebp-8] ; ecx = index
        ;mov ebx, DWORD PTR[ebp+16+ecx] ; ebx = z[index]
        ;add ebx, DWORD PTR[ebp-4] ; ebx += x
        ;mov DWORD PTR[ebp+16+ecx], ebx ; z[index] = ebx
        

        ;Epilogo da subrotina --------
        mov esp, ebp
        pop ebp
        ret 12; remove parametros da função

    ;Filtra a imagem
    _FilterImage:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp

        mov ebx, value_to_add ; aloca valor a ser incrementado em ebx
              
        _FilterImage_Loop:
            invoke ReadFile, original_fileHandle, addr bgr_color_buffer, 3, addr original_readCount, NULL ;Ler banda BGR
            
            mov ecx, offset bgr_color_buffer
            
            ;R Value
            mov eax, [ecx][2]
            push eax

            ;G Value
            mov eax, [ecx][1]
            push eax

            ;B Value
            mov eax, [ecx][0]
            push eax

            push eax
            call _Clamp
            mov edx, eax

            ;push offset bgr_color_buffer
            ;push 0 ; index
            ;push 50 ; valor pra add
            ;call _FilterPixel

            cmp color_index, 0
            je Filter_Blue
            cmp color_index, 1
            je Filter_Green
            cmp color_index, 2
            je Filter_Red

            Filter_Blue:
                pop eax
                mov DWORD PTR[ecx], edx ; B
                pop eax
                mov DWORD PTR[ecx+1], eax ; G
                pop eax
                mov DWORD PTR[ecx+2], eax ; R
                jmp Write_Data
            Filter_Green:
                pop eax
                mov DWORD PTR[ecx], eax ; B
                pop eax
                mov DWORD PTR[ecx+1], edx ; G
                pop eax
                mov DWORD PTR[ecx+2], eax ; R
                jmp Write_Data
            Filter_Red:
                pop eax
                mov DWORD PTR[ecx], eax ; B
                pop eax
                mov DWORD PTR[ecx+1], eax ; G
                pop eax
                mov DWORD PTR[ecx+2], edx ; R
                jmp Write_Data
             
            Write_Data:    
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
