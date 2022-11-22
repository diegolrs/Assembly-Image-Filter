.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib 

include remove_cr.inc

;-------------------------------
;Escreva um programa que some 7 ao numero inserido
;-------------------------------

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
nome_do_arquivo db 50 dup(0)


outputHandle dd 0 ; Variavel para armazenar o handle de saida
write_count dd 0; Variavel para armazenar caracteres escritos na console

.code
start:
    ;CONFIGURANDO STREAMS -----
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    MOV inputHandle, eax
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    MOV outputHandle, eax  

    ;Solicitar nome do arquivo de saída ------------
    mov console_write_count, 0
    invoke StrLen, addr msg_nome_arquivo
    mov tamanho_msg, eax
    invoke WriteConsole, outputHandle, addr msg_nome_arquivo, tamanho_msg, addr console_write_count, NULL


    ;LENDO STRING ----
    INVOKE ReadConsole, inputHandle, addr nome_do_arquivo, sizeof nome_do_arquivo, addr console_count, NULL

    push offset nome_do_arquivo
    call _RemoveCarriageReturn
        ;Escrevendo string --------------
    INVOKE StrLen, addr nome_do_arquivo
    MOV tamanho_out_string, eax
    INVOKE WriteConsole, outputHandle, addr nome_do_arquivo, tamanho_out_string, addr console_count, NULL
    ;----------------------------

    ;LENDO INPUT INTEIRA ----
    INVOKE ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL
    INVOKE StrLen, addr inputString
    MOV tamanho_string, eax

    push offset inputString
    call _RemoveCarriageReturn

    INVOKE atodw, addr inputString ; deixa inteiro convertido em eax
    MOV integer1, eax
    ADD integer1, 7
    MOV EAX, integer1
    INVOKE dwtoa, EAX, addr outputString
    INVOKE StrLen, addr outputString
    MOV tamanho_out_string, eax
    INVOKE WriteConsole, outputHandle, addr outputString, tamanho_out_string, addr console_count, NULL
    ;----------------------------

    ;Solicitar o index da cor ------------
    mov console_write_count, 0
    invoke StrLen, addr msg_index_cor
    mov tamanho_msg, eax
    invoke WriteConsole, outputHandle, addr msg_index_cor, tamanho_msg, addr console_write_count, NULL

    ;Solicitar a quantidade a adicionar na banda ------------
    mov console_write_count, 0
    invoke StrLen, addr msg_qtd_add
    mov tamanho_msg, eax
    invoke WriteConsole, outputHandle, addr msg_qtd_add, tamanho_msg, addr console_write_count, NULL

    FINALIZA:
    INVOKE ExitProcess, 0
end start