.data
    pega_x: .asciiz "Digite o valor de x: "
    resultado: .asciiz "Vai tomando o resultado de expx(x): "

    precisao: .float 0.00001 #precisao de ponto flutuante
    um_float: .float 1.0 
    
.text
.globl main

main:

    li $v0, 4  #imprime string em $a0   
    la $a0, pega_x 
    syscall

    li $v0, 6  # le o valor e armazena em f6
    syscall

    mov.s $f12, $f0 # move o x lido ($f0) para o registrador de argumento ($f12)
    
    jal exp_func #chama a funcao com o valor do registrador

    mov.s $f12, $f0 #move o valor resultado para $f0

    li $v0, 4    
    la $a0, resultado
    syscall

    li $v0, 2  #imprime resultado (float
    syscall

    #fim do programa
    li $v0, 10
    syscall

exp_func:
    l.s   $f10, precisao # 0.00001
    l.s   $f8, um_float # 1.0

    mov.s $f2, $f8 #soma = 1
    mov.s $f4, $f8 #termo = 1
    mov.s $f6, $f8 # n = 1

exp_loop:

    # t(k) = t(k-1)* (x/n)
    mul.s $f4, $f4, $f12 # t = t * x
    div.s $f4, $f4, $f6 # t = t / n
    
    add.s $f2, $f2, $f4 # soma = soma + t

    #incrementa
    add.s $f6, $f6, $f8 # n = n + 1

    # loop termina quando termo < precisao
    abs.s $f14, $f4 # $f14 = abs
    c.lt.s $f14, $f10 # compara abs(termo) < precisao
    bc1t fim_exp_loop # pula para o fim se a condição for verdadeira

    j exp_loop # se n pulou continua o loop

fim_exp_loop:
    # fim da funcao
    mov.s $f0, $f2 # mve o resultado final para o registrador de retorno $f0
    jr $ra # retorna para main
    