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

.code
start:
    xor eax, eax ;eax = 0

    Loop_Compare:
        cmp eax, 54
        jge Loop_Exit

        push eax
        printf("Valor de eax agora: %d\n", eax)
        pop eax 

    Loop_Increment:
        inc eax
        jmp Loop_Compare

    Loop_Exit:    
        invoke ExitProcess, 0
end start 
