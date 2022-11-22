.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib 

include remove_cr.inc

.data
inputString db 50 dup(0)
outputString db 50 dup(0)
inputHandle dd 0 ; Variavel para armazenar o handle de entradada
console_count dd 0 ; Variavel para armazenar caracteres lidos/escritos na console
tamanho_string dd 0 ; Variavel para armazenar tamanho de string terminada em 0
tamanho_out_string dd 0 ; Variavel para armazenar tamanho de string terminada em 0
integer1 dd 0

;Mensagens -------------------------
msg_nome_arquivo db "Insira o nome do arquivo de saida (ex: catita2.bmp): ", 0H
msg_index_cor db "Insira o index da banda BGR para alterar (B=0, G=1, R=2): ",  0H
msg_qtd_add db "Insira a quantidade a adicionar na banda [0, 255]: ", 0H
tamanho_msg dd 0 ; Variavel para armazenar tamanho da string de mensagem terminada em 0

;Variaveis ----------------------------
console_write_count dd 0 ; Variavel para armazenar caracteres lidos/escritos na console
outputHandle dd 0 ; Variavel para armazenar o handle de saida
write_count dd 0; Variavel para armazenar caracteres escritos na console


;Usados
inputInteger db 50 dup(0)

;Variaveis
nome_do_arquivo db 50 dup(0)
index_selecionado dd 0H
valor_para_adicionar dd 0H


.code

_RequestInteger:
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
    ;CONFIGURANDO STREAMS -----
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax  
    ; -------------

    ;Solicita nome do arquivo -----------------
        ;---- Printa mensagem ----
        invoke StrLen, addr msg_nome_arquivo
        invoke WriteConsole, outputHandle, addr msg_nome_arquivo, eax, addr console_write_count, NULL

        ;---- Aguarda e trata entrada ----
        invoke ReadConsole, inputHandle, addr nome_do_arquivo, sizeof nome_do_arquivo, addr console_count, NULL
        push offset nome_do_arquivo
        call _RemoveCarriageReturn

    ;Solicitar o index da cor ------------------
        ;---- Printa mensagem ----
        invoke StrLen, addr msg_index_cor
        invoke WriteConsole, outputHandle, addr msg_index_cor, eax, addr console_write_count, NULL

        ;---- Aguarda e trata entrada ----
        call _RequestInteger
        mov index_selecionado, eax

    ;Solicitar valor para adicionar ------------
        ;---- Printa mensagem ----
        invoke StrLen, addr msg_qtd_add
        invoke WriteConsole, outputHandle, addr msg_qtd_add, eax, addr console_write_count, NULL

        ;---- Aguarda e trata entrada ----
        call _RequestInteger
        mov valor_para_adicionar, eax


    ;Escrevendo strings --------------
    INVOKE StrLen, addr nome_do_arquivo
    MOV tamanho_out_string, eax
    INVOKE WriteConsole, outputHandle, addr nome_do_arquivo, tamanho_out_string, addr console_count, NULL

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