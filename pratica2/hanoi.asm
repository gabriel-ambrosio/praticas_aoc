.data
msg_disco:    .asciiz "Move disco do pino "
msg_para:     .asciiz " para o pino "
nova_linha:   .asciiz "\n"
msg_pergunta: .asciiz "Numero de discos? "

.text
.globl main

main:
    li $v0, 4 #printa a mensagem
    la $a0, msg_pergunta
    syscall

    li $v0, 5 #pega o valor dos numeros de discos
    syscall
    
    
    move $a0, $v0 # $a0 = n
    li $a1, 'A' #prepara os argumentos   
    li $a2, 'B' 
    li $a3, 'C'  

    jal hanoi


    li $v0, 10 #goodbye
    syscall


#   $a0: n, $a1 'de', $a2 'via', $a3 'para'
hanoi:
    # como a gente vai fazer varias chamadas recursivas, vamos salver os dados na pilha
    # para poder ser restaurado quando necessario.
    # salvo 5 registradores (4 args + 1 de retorno), então 5 * 4 = 20 bytes.
    addi $sp, $sp, -20
    sw $ra, 16($sp)  # salva o endereço de retorno
    sw $a0, 12($sp)  # salva n
    sw $a1, 8($sp)   # salva pino 'de'
    sw $a2, 4($sp)   # salva pino 'via'
    sw $a3, 0($sp)   # salva pino 'para'

    # mudei um pouco a logica do programa pra ficar mais facil
    #inves de comparar com n maior que 1, checa com 0 para poder printar com n = 1
    blez $a0, hanoi_fim # Branch if Less Than or Equal to Zero -> vai para hanoi fim
    # primeira chamada: hanoi(n-1, de, para, via)
    addi $a0, $a0, -1 # n = n - 1
    # troca os pinos 'via' e 'para' e chama dnv
    move $t0, $a2     # t0 = via
    move $a2, $a3     # via = para
    move $a3, $t0     # para = t0 (antigo via)
    jal hanoi

    # impressao do pino atual
    # como modificador os a0-3, temos que restauralos na pilha
    lw $a0, 12($sp)  # restaura n original
    lw $a1, 8($sp)   # restaura pino 'de' original
    lw $a3, 0($sp)   # restaura pino 'para' original

    # "move do disco "
    li $v0, 4
    la $t0, msg_disco
    move $a0, $t0
    syscall
    
    li $v0, 11       # imprime char
    move $a0, $a1    # imprime o pino 'de'
    syscall

    # "para o pino "
    li $v0, 4
    la $t0, msg_para
    move $a0, $t0
    syscall
    
    li $v0, 11
    move $a0, $a3    # Imprime o pino 'para'
    syscall

    li $v0, 4 #pula linha pra proxima rodada de movimentacoes
    la $a0, nova_linha 
    syscall

    # segunda chamada: hanoi(n-1, via, de, para)
    # precisa restaurar os args pra nao dar bo
    lw $a0, 12($sp)  # n
    lw $a1, 8($sp)   # de
    lw $a2, 4($sp)   # via
    lw $a3, 0($sp)   # para

    addi $a0, $a0, -1 # n = n - 1
    move $t0, $a1     # t0 = de
    move $a1, $a2     # de = via
    move $a2, $t0     # via = t0 (antigo de)
    jal hanoi

hanoi_fim:
    # restauraa o contexto da pilha e retornaa
    lw $ra, 16($sp)
    lw $a0, 12($sp)
    lw $a1, 8($sp)
    lw $a2, 4($sp)
    lw $a3, 0($sp)
    addi $sp, $sp, 20 # libera o espaco alocado na pilha

    jr $ra            # retorna
