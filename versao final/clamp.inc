;--------------------------
; Clampa cor para nao passar de 255
; params: valor a ser clampado
; Nota: o valor clampado eh salvo no registrador EAX
.code
_Clamp PROC
    ;Prologo da subrotina --------
    push ebp
    mov ebp, esp

    ;eax=param
    xor eax, eax
    mov eax, DWORD PTR[ebp+8]

    ; verifica se tem algum digito diferente de zero nos 8 bits depois de 255
    cmp ah, 0H 
    jne _Clamp_Max 
    
    ; como nao ha digito diferente de zero nos primeiros 8 bits mas significantes, o numero eh menor ou igual a 255
    jmp _Clamp_Return

    ;Coloca valor maximo (255) no registrador -----
    _Clamp_Max:
        xor eax, eax
        mov al, 0FFH ; 255        

    ;Epilogo da subrotina --------   
    _Clamp_Return:
        mov esp, ebp
        pop ebp
        ret 4; desaloca parametro
_Clamp ENDP