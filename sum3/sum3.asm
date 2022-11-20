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
    num2 dd 2
    num3 dd 30

.code
;params: num1, num2, num3
_sum3:
    ;Prologo da subrotina --------
    push ebp
    mov ebp, esp
    sub esp, 12

    ;x = 30
    mov eax, DWORD PTR[ebp+8]
    mov DWORD PTR[ebp-4], eax

    ;y = 2
    mov eax, DWORD PTR[ebp+12]
    mov DWORD PTR[ebp-8], eax

    ;z = 500*2
    mov eax, DWORD PTR[ebp+16]
    add eax, eax
    mov DWORD PTR[ebp-12], eax

    xor eax, eax
    add eax, DWORD PTR[ebp-12]
    sub eax, DWORD PTR[ebp-8]
    add eax, DWORD PTR[ebp-4]

    ;Epilogo da subrotina --------
    mov esp, ebp
    pop ebp
    ret 12; remove parametros da função

_sumref:
    ;Prologo da subrotina --------
    push ebp
    mov ebp, esp
    sub esp, 4

    ;Pegando valor no endereco e modificando
    mov eax, DWORD PTR[ebp+8] ; x = param
    mov eax, [eax]
    add eax, 82 ; soma com valor constante

    mov ebx, [ebp+8] ;
    mov DWORD PTR[ebx], eax

    ;usando como ponteiro --------
    ;mov eax, DWORD PTR[ebp-4] ; salvando endereço em eax
    ;mov eax, [eax] ; pegando valor
    ;add eax, 62 ; alterando valor
    ;mov DWORD PTR[ebp-4], eax
    
    ;Epilogo da subrotina --------
    mov esp, ebp
    pop ebp
    ret 4; remove parametros da função


start:
    push offset num1
    call _sumref
    printf("%d\n", num1)

    invoke ExitProcess, 0
end start 
