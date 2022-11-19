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
 entrada dd -25

.code
    _Clamp:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
   
        ;eax=param
        mov eax, DWORD PTR[ebp+8]

        _Clamp_Compara:
            cmp eax, 0
            jl _Clamp_Menor
            cmp eax, 255
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

start:
    push entrada
    call _Clamp
    mov entrada, eax
    
    printf("Valor clampado %d\n", entrada)      
    invoke ExitProcess, 0
end start
