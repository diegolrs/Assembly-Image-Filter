.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib 

include console-messages.inc
include myIO.inc

.data
;Variaveis ----------
buffer_NomeDoArquivo db 50 dup(0)
index_selecionado dd 0H
valor_para_adicionar dd 0H

.code
start:
    call _MyIO_Setup

    ;Solicita nome do arquivo -----------------
        ;---- Printa mensagem ----
        push offset CONSOLE_MSG_NOME_ARQUIVO
        call _MyIO_LogMessage

        ;---- Aguarda e trata entrada ----
        push sizeof buffer_NomeDoArquivo
        push offset buffer_NomeDoArquivo
        call _MyIO_ReadString

    ;Solicitar o index da cor ------------------
        ;---- Printa mensagem ----
        push offset CONSOLE_MSG_INDEX_COR
        call _MyIO_LogMessage

        ;---- Aguarda e trata entrada ----
        call _MyIO_ReadInteger
        mov index_selecionado, eax

    ;Solicitar valor para adicionar ------------
        ;---- Printa mensagem ----
        push offset CONSOLE_MSG_QTD_ADD
        call _MyIO_LogMessage

        ;---- Aguarda e trata entrada ----
        call _MyIO_ReadInteger
        mov valor_para_adicionar, eax


    ;Escrevendo strings --------------
    push offset buffer_NomeDoArquivo
    call _MyIO_LogMessage

    mov eax, index_selecionado
    invoke dwtoa, eax, addr inputInteger
    push offset inputInteger
    call _MyIO_LogMessage

    mov eax, valor_para_adicionar
    invoke dwtoa, eax, addr inputInteger
    push offset inputInteger
    call _MyIO_LogMessage
    ;----------------------------

    INVOKE ExitProcess, 0
end start