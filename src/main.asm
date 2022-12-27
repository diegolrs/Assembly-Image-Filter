.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

;Libraries created
include clamp.inc
include console-messages.inc
include myIO.inc

.data
    ;Read file variables
    inputImage_fileHandle dd 0H
    inputImage_readCount dd 0H

    ;Write file variables
    outputImage_fileHandle dd 0H
    outputImage_writeCount dd 0H

    ;File Buffers
    read_buffer_size dd 1H
    inputImage_fileBuffer db 54 dup(0)
    bgr_color_buffer byte 3 DUP(0)
    
    ;Core variables
    color_index dd 1H ; index to operate
    value_to_add dd 0H ; value to add
    outputImage_name db 50 dup(0) ; name of output image file
    inputImage_name db 50 dup(0) ; name of input image file

.code   
;Copy the first 54 bytes of the input image to the output image file
    _CopyFirst54Bytes:
        ;Prologue of the subroutine --------
        push ebp
        mov ebp, esp
        
        ;Read input image
        invoke ReadFile, inputImage_fileHandle, addr inputImage_fileBuffer, 54, addr inputImage_readCount, NULL 

        ;Write readed buffer to output image
        invoke WriteFile, outputImage_fileHandle, addr inputImage_fileBuffer, 54, addr outputImage_writeCount, NULL ; Escreve os 54 bytes do arquivo

        ;Epilogue of the subroutine --------
        mov esp, ebp
        pop ebp
        ret


    ;Filter pixel by adding value to one of the color bands
    ;params: BGR array address, band index to operate, value to add
    ;Note: modifies the EAX, ECX and EDX registers
    _FilterPixel:
        ;Prologue of the subroutine --------
        push ebp
        mov ebp, esp
        sub esp, 12

        ;value to add
        mov eax, DWORD PTR[ebp+8]
        mov DWORD PTR[ebp-4], eax

        ;index to operate
        mov eax, DWORD PTR[ebp+12]
        mov DWORD PTR[ebp-8], eax

        ;BGR array address
        mov eax, DWORD PTR[ebp+16]
        mov DWORD PTR[ebp-12], eax
        mov ecx, DWORD PTR[ebp-12]

        ;R-Band
        mov eax, [ecx][2]
        push eax

        ;G-Band
        mov eax, [ecx][1]
        push eax

        ;B-Band
        mov eax, [ecx][0]
        push eax

        ;----- Getting value in the desired band (using index) -------
        cmp DWORD PTR[ebp-8], 0 
        je _FilterPixel_AddValue ; when index == 0, you do not need to configure anything, because the zero index value is already in eax
        cmp DWORD PTR[ebp-8], 1
        je _FilterPixel_OnIndexEquals1 ; when index == 1
        cmp DWORD PTR[ebp-8], 2
        je _FilterPixel_OnIndexEquals2 ; when index == 2

        _FilterPixel_OnIndexEquals1:
            mov eax, [ecx][1]
            jmp _FilterPixel_AddValue

        _FilterPixel_OnIndexEquals2:           
            mov eax, [ecx][2]
            jmp _FilterPixel_AddValue

        ;Add value in the chosen band
        _FilterPixel_AddValue:
            xor ah, ah ; ah = 0
            add eax, DWORD PTR[ebp-4]

        ;Clamp new value in range [0, 255] -----------
        _FilterPixel_Clamp:
            push eax
            call _Clamp
            mov edx, eax

        ;----------- Filtering image adding value in chosen color band --------------
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
            ;Epilogue of the subroutine --------
            mov esp, ebp
            pop ebp
            ret 12 ;deallocate function parameters


    ;Filters the image, applying the filter logic to each pixel
    _FilterImage:
        ;Prologue of the subroutine --------
        push ebp
        mov ebp, esp
        sub esp, 12

        ;value to add
        mov eax, DWORD PTR[ebp+8]
        mov DWORD PTR[ebp-4], eax

        ;index to operate
        mov eax, DWORD PTR[ebp+12]
        mov DWORD PTR[ebp-8], eax

        ;brg offset
        mov eax, DWORD PTR[ebp+16]
        mov DWORD PTR[ebp-12], eax
              
        _FilterImage_Loop:
            ;Read BGR pixel
            invoke ReadFile, inputImage_fileHandle, addr bgr_color_buffer, 3, addr inputImage_readCount, NULL

            ;Filter readed pixel
            push DWORD PTR[ebp-12] ; BGR array address
            push DWORD PTR[ebp-8] ; index
            push DWORD PTR[ebp-4] ; value to add
            call _FilterPixel

            ;Write BGR pixel to file
            invoke WriteFile, outputImage_fileHandle, addr bgr_color_buffer, 3, addr outputImage_writeCount, NULL        

            ;Verifies EOF ---------
            cmp inputImage_readCount, 0
            je _FilterImage_Return
            jne _FilterImage_Loop
        
        _FilterImage_Return:
            pop ebx
            ;Epilogue of the subroutine --------
            mov esp, ebp
            pop ebp
            ret 12 ;deallocate parameters


    ;Read the input data to apply in the program
    _ReadInputs:
        ;Prologue of the subroutine --------
        push ebp
        mov ebp, esp
        
        ;Request input file name -----------------
            ;---- Print message ----
            push offset CONSOLE_MSG_INPUT_IMG_FILENAME
            call _MyIO_LogMessage

            ;---- Wait and handle input ----
            push sizeof inputImage_name
            push offset inputImage_name
            call _MyIO_ReadString
            
        ;Request output file name -----------------
            ;---- Print message ----
            push offset CONSOLE_MSG_OUTPUT_IMG_FILENAME
            call _MyIO_LogMessage

            ;---- Wait and handle input ----
            push sizeof outputImage_name
            push offset outputImage_name
            call _MyIO_ReadString

        ;Request color band index ------------------
            ;---- Print message ----
            push offset CONSOLE_MSG_INDEX_COLORBAND
            call _MyIO_LogMessage
    
            ;---- Wait and handle input ----
            call _MyIO_ReadInteger
            mov color_index, eax
    
        ;Request value to add in the band ------------
            ;---- Print message ----
            push offset CONSOLE_MSG_VALUE_TO_ADD
            call _MyIO_LogMessage
    
            ;---- Wait and handle input ----
            call _MyIO_ReadInteger
            mov value_to_add, eax

        ;Epilogue of the subroutine --------
        mov esp, ebp
        pop ebp
        ret ;deallocate parameters

        
start:
    call _MyIO_Setup ; Console input and output handler setup
    call _ReadInputs ; Receives and processes entries, saving them in memory

    ; Open input image and then request reading mode ----------
    invoke CreateFile, addr inputImage_name, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov inputImage_fileHandle, eax   

    ; Create output image and request writing mode ----------
    invoke CreateFile, addr outputImage_name, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov outputImage_fileHandle, eax

    ;Copies first 54 bytes of the image
    call _CopyFirst54Bytes

    ;Filters BGR image pixels
    push offset bgr_color_buffer
    push color_index
    push value_to_add  
    call _FilterImage
    
    ;Close the files and exit the program
    invoke CloseHandle, inputImage_fileHandle
    invoke CloseHandle, outputImage_fileHandle    
    invoke ExitProcess, 0
end start