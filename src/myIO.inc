;-------------------------
; Library created to handle input and output commands

include remove-cr.inc

.data
;Console variables -------
inputInteger db 50 dup(0) ; Buffer variable to receive integers via console
console_write_count dd 0 ; Variable to store characters read/written in the console
write_count dd 0 ; Variable to store characters written in the console

;Console handlers ----
inputHandle dd 0 ; Variable to store the input handle
outputHandle dd 0 ; Variable to store the output handle
console_count dd 0 ; Variable to store characters read/written in the console

.code

; Initialize input and output handlers to make use of MyIO functions ----
; Note: modifies EAX register
_MyIO_Setup PROC
    ;Prologue of the subroutine --------
    push ebp
    mov ebp, esp
    
    ;Configuring streams -----
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax  

    ;Epilogue of the subroutine --------   
    mov esp, ebp
    pop ebp
    ret
_MyIO_Setup ENDP


; Print message to console --------
; param: offset string
; Note: modifies EAX register
_MyIO_LogMessage PROC
    ;Prologue of the subroutine --------
    push ebp
    mov ebp, esp
    sub esp, 4

    ;getting the address of the parameter string
    mov eax, DWORD PTR[ebp+8]
    mov DWORD PTR[ebp-4], eax
    
    invoke StrLen, DWORD PTR[ebp-4]
    invoke WriteConsole, outputHandle, DWORD PTR[ebp-4], eax, addr console_count, NULL

    ;Epilogue of the subroutine --------   
    mov esp, ebp
    pop ebp
    ret 4 ; returns and deallocates parameter (string address)
_MyIO_LogMessage ENDP


; Receives and handles console input, removing CR character of the input string --------
; param: sizeof string, offset string
; Note: modifies EAX and ESI registers
_MyIO_ReadString PROC
    ;Prologue of the subroutine --------
    push ebp
    mov ebp, esp
 
    invoke ReadConsole, inputHandle, DWORD PTR[ebp+8], DWORD PTR[ebp+12], addr console_count, NULL

    mov eax, DWORD PTR[ebp+8]
    push eax
    call _RemoveCarriageReturn

    ;Epilogue of the subroutine --------   
    mov esp, ebp
    pop ebp
    ret 8 ; deallocates both two parameters
_MyIO_ReadString ENDP
    

; Receives and handles console input, returning an integer in EAX --------
; Note: modifies both EAX and ESI registers
; return: retorns the integer readed in EAX register
_MyIO_ReadInteger PROC
    ;Prologue of the subroutine --------
    push ebp
    mov ebp, esp
    
    ;Read from console
    invoke ReadConsole, inputHandle, addr inputInteger, sizeof inputInteger, addr console_count, NULL

    ;Removing CR character
    push offset inputInteger
    call _RemoveCarriageReturn

    ;Call conversion
    invoke atodw, addr inputInteger ; the output integer will be saved in EAX

    ;Epilogue of the subroutine --------   
    mov esp, ebp
    pop ebp
    ret
_MyIO_ReadInteger ENDP

