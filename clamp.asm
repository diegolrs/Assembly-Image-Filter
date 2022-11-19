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
 entrada dd 85

.code
    _Clamp:
        ;Prologo da subrotina --------
        push ebp
        mov ebp, esp
        sub esp, 12 ;12 bytes reservados para as variáveis locais

        ;min=0
        mov DWORD PTR[ebp-4], 0

        ;max=255
        mov DWORD PTR[ebp-8], 255

        ;y=param
        mov eax, DWORD PTR[ebp+8]
        mov DWORD PTR[ebp-8], eax

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
            
        _Clamp_Return:
            ;Epilogo da subrotina --------
            mov esp, ebp
            pop ebp
            ret 4

start:
    push entrada
    call _Clamp
    mov entrada, eax
    
    printf("Valor clampado %d\n", entrada)      
    invoke ExitProcess, 0
end start
