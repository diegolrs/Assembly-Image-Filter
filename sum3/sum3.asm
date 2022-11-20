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
;params: num1, num2, num3
_sum3:
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

    xor eax, eax
    add eax, DWORD PTR[ebp-12]
    sub eax, DWORD PTR[ebp-8]
    add eax, DWORD PTR[ebp-4]

    ;Epilogo da subrotina --------
    mov esp, ebp
    pop ebp
    ret 12; remove parametros da função


start:
    push 50
    push 20
    push 32
    call _sum3
    printf("%d", eax)

    invoke ExitProcess, 0
end start 
