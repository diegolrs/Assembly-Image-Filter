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
    num1 dd 500
    
.code
;Modifica por referência um endereço

_sumref:
    ;Prologo da subrotina --------
    push ebp
    mov ebp, esp

    ;Pegando valor no endereco e modificando
    mov eax, DWORD PTR[ebp+8] ; x = param
    mov eax, [eax] ; resgatando valor no endereço
    add eax, 82 ; soma com valor constante

    mov ebx, [ebp+8] ; ponteiro de pointeiro
    mov DWORD PTR[ebx], eax ; colocando valor indiretamente
    
    ;Epilogo da subrotina --------
    mov esp, ebp
    pop ebp
    ret 4; remove parametro da função

start:
    push offset num1
    call _sumref
    printf("%d\n", num1)

    invoke ExitProcess, 0
end start 
