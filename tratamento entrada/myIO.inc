
;-------------------------
;   Criado para facilitar os comandos de entrada e saida
;-------------------------

;include \masm32\include\windows.inc
;include \masm32\include\kernel32.inc
;include \masm32\include\masm32.inc
;includelib \masm32\lib\kernel32.lib
;includelib \masm32\lib\masm32.lib 

include remove-cr.inc

.data
;Console variables -------
inputInteger db 50 dup(0)
console_write_count dd 0 ; Variavel para armazenar caracteres lidos/escritos na console
write_count dd 0; Variavel para armazenar caracteres escritos na console

;Console handlers ----
inputHandle dd 0 ; Variavel para armazenar o handle de entrada
outputHandle dd 0 ; Variavel para armazenar o handle de saida
console_count dd 0 ; Variavel para armazenar caracteres lidos/escritos na console

.code
_MyIO_Setup PROC
    ;Prologo da subrotina --------
    push ebp
    mov ebp, esp
    
    ;Configurando streams -----
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax  

    ;Epilogo da subrotina --------   
    mov esp, ebp
    pop ebp
    ret
_MyIO_Setup ENDP


; Printa mensagem no console --------
; param: offset string
; Nota: modifica registrador EAX
_MyIO_LogMessage PROC
    ;Prologo da subrotina --------
    push ebp
    mov ebp, esp
    sub esp, 4

    ;endereco da string passada
    mov eax, DWORD PTR[ebp+8]
    mov DWORD PTR[ebp-4], eax
    
    invoke StrLen, DWORD PTR[ebp-4]
    invoke WriteConsole, outputHandle, DWORD PTR[ebp-4], eax, addr console_count, NULL

    ;Epilogo da subrotina --------   
    mov esp, ebp
    pop ebp
    ret 4 ; retorna e desimpilha parametro local criado
_MyIO_LogMessage ENDP


; Recebe e trata entrada do console --------
; param: offset string, string size
; Nota: modifica registradores EAX e ESI
_MyIO_ReadString PROC
    ;Prologo da subrotina --------
    push ebp
    mov ebp, esp
 
    invoke ReadConsole, inputHandle, DWORD PTR[ebp+8], DWORD PTR[ebp+12], addr console_count, NULL

    mov eax, DWORD PTR[ebp+8]
    push eax
    call _RemoveCarriageReturn

    ;Epilogo da subrotina --------   
    mov esp, ebp
    pop ebp
    ret 8 ; desimpilha os dois parametros
_MyIO_ReadString ENDP
    

; Recebe e trata entrada do console, devolvendo um inteiro em EAX --------
; param: offset string, string size
; Nota: modifica registradores EAX e ESI
_MyIO_ReadInteger PROC
    ;Prologo da subrotina --------
    push ebp
    mov ebp, esp
    
    ;Faz leitura do console
    invoke ReadConsole, inputHandle, addr inputInteger, sizeof inputInteger, addr console_count, NULL

    ;Remove enter
    push offset inputInteger
    call _RemoveCarriageReturn

    ;Salva conversao em EAX
    invoke atodw, addr inputInteger ; deixa inteiro convertido em eax

    ;Epilogo da subrotina --------   
    mov esp, ebp
    pop ebp
    ret
_MyIO_ReadInteger ENDP

