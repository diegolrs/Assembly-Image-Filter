; RETIRANDO CARRIAGE RETURN (CR, ENTER)
; parametro: offset de uma string a ser tratada
.code
_RemoveCarriageReturn PROC
    ;Prologo da subrotina --------
    push ebp
    mov ebp, esp

    ;esi=param
    mov esi, DWORD PTR[ebp+8] ; Armazenar apontador da string em esi
    
    _RemoveCarriageReturn_proximo:
        mov al, [esi] ; Mover caracter atual para al
        inc esi ; Apontar para o proximo caracter
        cmp al, 46 ; Verificar se menor que ASCII 46 - FINALIZAR
        jl _RemoveCarriageReturn_terminar
        cmp al, 123 ; Verificar se menor que ASCII 123 - CONTINUAR
        jl _RemoveCarriageReturn_proximo
    _RemoveCarriageReturn_terminar:
        dec esi ; Apontar para caracter anterior
        xor al, al ; 0 ou NULL
        mov [esi], al ; Inserir NULL logo apos o termino do numero

    ;Epilogo da subrotina --------   
    mov esp, ebp
    pop ebp
    ret 4 ; retorna e desaloca parametro (endereco da string)
_RemoveCarriageReturn ENDP