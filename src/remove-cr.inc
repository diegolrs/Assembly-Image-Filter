; Removing Carriage Return (CR, Enter)
; params: offset of a string to be treated
.code
_RemoveCarriageReturn PROC
    ;Prologue of the subroutine --------
    push ebp
    mov ebp, esp

    ;esi=param
    mov esi, DWORD PTR[ebp+8] ; Store string pointer in esi
    
    _RemoveCarriageReturn_Next:
        mov al, [esi] ; Move current character to al
        inc esi ; Point to the next character
        cmp al, 46 ; Check if less than ASCII 46 - FINALIZE
        jl _RemoveCarriageReturn_End
        cmp al, 123 ; Check if less than ASCII 123 - CONTINUE
        jl _RemoveCarriageReturn_Next
    _RemoveCarriageReturn_End:
         dec esi ; Point to previous character
         xor al, al ; 0 or NULL
         mov [esi], al ; Insert NULL right after the end of the number

    ;Epilogue of the subroutine --------   
    mov esp, ebp
    pop ebp
    ret 4 ; returns and deallocates parameter (string address)
_RemoveCarriageReturn ENDP