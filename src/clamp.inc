;--------------------------
; Clamp color to not exceed 255
; param: value to be clamped
; Note: the clamped value is saved in the EAX register
.code
_Clamp PROC
    ;Prologue of the subroutine --------
    push ebp
    mov ebp, esp

    ;eax=param
    xor eax, eax
    mov eax, DWORD PTR[ebp+8]

    ;checks if there are any non-zero digits in the 8 bits after 255
    cmp ah, 0H 
    jne _Clamp_Max 
    
    ;there are no nonzero digits in the first 8 most significant bits, so number <= 255
    jmp _Clamp_Return

    ;store maximum value (255) in register -----
    _Clamp_Max:
        xor eax, eax
        mov al, 0FFH ; 255        

    ;Epilogue of the subroutine --------   
    _Clamp_Return:
        mov esp, ebp
        pop ebp
        ret 4 ; deallocate parameter
_Clamp ENDP