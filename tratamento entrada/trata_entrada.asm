.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib 

include remove-cr.inc
include console-messages.inc

.data
;Console variables -------
inputInteger db 50 dup(0)
console_write_count dd 0 ; Variavel para armazenar caracteres lidos/escritos na console
write_count dd 0; Variavel para armazenar caracteres escritos na console

;Console handlers ----
inputHandle dd 0 ; Variavel para armazenar o handle de entrada
outputHandle dd 0 ; Variavel para armazenar o handle de saida
console_count dd 0 ; Variavel para armazenar caracteres lidos/escritos na console

;Variaveis ----------
buffer_NomeDoArquivo db 50 dup(0)
index_selecionado dd 0H
valor_para_adicionar dd 0H

.code
_SetupIO:
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

; Printa mensagem no console --------
; param: offset string
; Nota: modifica registrador EAX
_LogMessage:
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
    

; Recebe e trata entrada do console --------
; param: offset string, string size
; Nota: modifica registradores EAX e ESI
_ReadString:
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
    

; Recebe e trata entrada do console, devolvendo um inteiro em EAX --------
; param: offset string, string size
; Nota: modifica registradores EAX e ESI
_ReadInteger:
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
    
start:
    call _SetupIO

    ;Solicita nome do arquivo -----------------
        ;---- Printa mensagem ----
        push offset CONSOLE_MSG_NOME_ARQUIVO
        call _LogMessage

        ;---- Aguarda e trata entrada ----
        push sizeof buffer_NomeDoArquivo
        push offset buffer_NomeDoArquivo
        call _ReadString

    ;Solicitar o index da cor ------------------
        ;---- Printa mensagem ----
        push offset CONSOLE_MSG_INDEX_COR
        call _LogMessage

        ;---- Aguarda e trata entrada ----
        call _ReadInteger
        mov index_selecionado, eax

    ;Solicitar valor para adicionar ------------
        ;---- Printa mensagem ----
        push offset CONSOLE_MSG_QTD_ADD
        call _LogMessage

        ;---- Aguarda e trata entrada ----
        call _ReadInteger
        mov valor_para_adicionar, eax


    ;Escrevendo strings --------------
    INVOKE StrLen, addr buffer_NomeDoArquivo
    INVOKE WriteConsole, outputHandle, addr buffer_NomeDoArquivo, eax, addr console_count, NULL

    mov eax, index_selecionado
    invoke dwtoa, eax, addr inputInteger
    INVOKE StrLen, addr inputInteger
    INVOKE WriteConsole, outputHandle, addr inputInteger, eax, addr console_count, NULL

    mov eax, valor_para_adicionar
    invoke dwtoa, eax, addr inputInteger
    INVOKE StrLen, addr inputInteger
    INVOKE WriteConsole, outputHandle, addr inputInteger, eax, addr console_count, NULL
    ;----------------------------


    INVOKE ExitProcess, 0
end start