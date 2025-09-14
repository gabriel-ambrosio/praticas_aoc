.data
msg_n:      .asciiz "Digite n (numero de linhas): "
msg_m:      .asciiz "Digite m (numero de colunas): "
msg_leval:   .asciiz "\nDigite os valores (floats) da matriz A, por cada linha:\n"
msg_colx:   .asciiz "\nDigite indice da coluna X(0- calorias; 1- glicidios; 2- lipidios; 3- proteinas ): "
msg_coly:   .asciiz "Digite indice da coluna Y: "
msg_result:    .asciiz "\nCorrelacao = "

.text
.globl main

main:
    # le n
    li   $v0, 4 	#syscall 4, imprime string
    la   $a0, msg_n
    syscall
    li   $v0, 5        #syscall 5, le int
    syscall
    move $s1, $v0      #coloca n no em um registrador Saved $s1

    # le m
    li   $v0, 4		#syscall 4, imprime string
    la   $a0, msg_m
    syscall
    li   $v0, 5		 #syscall 5, le int
    syscall
    move $s2, $v0      #coloca m em um registrador Saved $s2
    
    # calcular tamanho da matriz = n * m * 4 pois float tem 4 bytes
    move $t0, $s1
    mul  $t0, $t0, $s2   # t0 = n*m
    li   $t1, 4
    mul  $t0, $t0, $t1   # t0 = n*m*4

    # alocar memoria
    move $a0, $t0 #a0 tem o tamanho de bytes da matriz desejada
    li   $v0, 9 #chama syscall 9 sbrk que vai abrir espaco pra gente
    syscall
    move $s0, $v0        #sbrk retorna v0 apontando para o endereco do bloco, agora s0 aponta

    #  le os valores float
    li   $v0, 4
    la   $a0, msg_leval
    syscall

    # le n*m floats e armazenar sequencialmente no bloco de memória
    # vamos usar t2 como ponteiro para alocacao
    move $t2, $s0	#t2 vai apontar para o bloco
    move $t3, $s1        # $s1 tem n (numero de linhas)
    mul  $t3, $t3, $s2   # t3 = n*m (contador total)
    li   $t4, 0          # i = 0

ler_val_loop:
    beq  $t4, $t3, ler_val_fim #se i = n*m, para
    
    # syscall 6 le float e retorn em $f0
    li   $v0, 6
    syscall

    # armazenar $f0 no espaco de memoria que $t2 esta apontando, uso swc por facilidade em entender o mnemonico
    swc1 $f0, 0($t2)

    addi $t2, $t2, 4 #t2 vai apontar para o proximo float, +4 bytes
    addi $t4, $t4, 1 #i++
    j    ler_val_loop #reinicia o loop

ler_val_fim:
    # le coluna X
    li   $v0, 4
    la   $a0, msg_colx
    syscall
    li   $v0, 5
    syscall
    move $t5, $v0   # $t5 = colX

    # le coluna Y
    li   $v0, 4
    la   $a0, msg_coly
    syscall
    li   $v0, 5
    syscall
    move $t6, $v0   # $t6 = colY

    # passar os valoras para os $ai (registradores de argumento) e chamar correlacao
    move $a0, $s0   # endereco do bloco da matriz
    move $a1, $s1   # n(numero de linhas da matriz)
    move $a2, $s2   # m(numero de colunas da matriz)
    move $a3, $t5   # coluna X da matriz
    move $t0, $t6   # coluna Y da matriz (como tem 5 argumentos, passei por t0, pra nao passar por pilha)
    jal  correlacao

    # imprime a string result
    li   $v0, 4
    la   $a0, msg_result
    syscall
    #imprime o valor calculado na func correlacao
    li   $v0, 2
    mov.s $f12, $f0 #move para o f12 pq eh onde o syscall espera o resultado
    syscall


    li   $v0, 10 #syscal 10, exit
    syscall



# retorna $f0 = correlacao
correlacao:
    addi $sp, $sp, -48 #abre espaco na pilha de 48 bytes
    sw   $ra, 44($sp) #garante que o return adress nao vai sumir quando chamar outra func
    sw   $s0, 40($sp) #pra baixo, registrador $si, sao salvos, entao tenho que garantir que quando sair da func
    sw   $s1, 36($sp) # eles nao vao ser alterados.
    sw   $s2, 32($sp)
    sw   $s3, 28($sp)
    sw   $s4, 24($sp)
    sw   $s5, 20($sp)
    
    #passando os argumentos para serem usados
    move $s0, $a0    # base do bloco da matriz
    move $s1, $a1    # n
    move $s2, $a2    # m
    move $s3, $a3    # colX
    move $s4, $t0    # colY
    
    #inicializando as somas
    # somaX = 0.0 em $f0
    li   $t1, 0
    mtc1 $t1, $f0 #f0 = 0;
    cvt.s.w $f0, $f0 #converte o valor de 0 para 0.0, word to singleprecision

    # somaY = 0.0 in $f2
    mtc1 $t1, $f2 #ja usa o t1 de cima
    cvt.s.w $f2, $f2 #converte o valor de 0 para 0.0, word to singleprecision

    li   $t2, 0     # i = 0

calc_media_loop:
    beq  $t2, $s1, calc_media_feita # i == n

    # addr_x = base + ((i * m) + colX) * 4
    # quero pegar todos os x para somar, addr_x faz isso, vai ser usado varias vezes; (carrega xi || carrega yi)
    mul  $t3, $t2, $s2    # i * m
    add  $t3, $t3, $s3    # + colX
    sll  $t3, $t3, 2      #desloca 2 bits pra esquerda, = *4, por causa do float ter 4 bytes 
    addu $t4, $s0, $t3    # base + ... = base + $t3
    lwc1 $f4, 0($t4)      #finalmente, achamos o valor de xi que queremos
    
    # addr_y
    # mesma coisa de addr_x
    mul  $t3, $t2, $s2
    add  $t3, $t3, $s4
    sll  $t3, $t3, 2 #desloca 2 bits pra esquerda, = *4, por causa do float ter 4 bytes
    addu $t4, $s0, $t3
    lwc1 $f6, 0($t4) 	#valor de yi que queremos

    add.s $f0, $f0, $f4 #somaX = somaX + xi
    add.s $f2, $f2, $f6 #somaY = somaY = yi

    addi $t2, $t2, 1 #i++
    j    calc_media_loop

calc_media_feita:
    # mx = somaX / n; resultado em $f10
    mtc1 $s1, $f8
    cvt.s.w $f8, $f8
    div.s $f10, $f0, $f8

    # my = somaY / n; resultado em $f12
    div.s $f12, $f2, $f8

    # inicializa Sxx, Syy, Sxy = 0
    mtc1 $t1, $f14
    cvt.s.w $f14, $f14
    mtc1 $t1, $f16
    cvt.s.w $f16, $f16
    mtc1 $t1, $f18
    cvt.s.w $f18, $f18

    li   $t2, 0 #j == 0

calc_soma_loop:
    beq  $t2, $s1, calc_soma_feita #j == n

    # carrega x1
    mul  $t3, $t2, $s2
    add  $t3, $t3, $s3
    sll  $t3, $t3, 2
    addu $t4, $s0, $t3
    lwc1 $f4, 0($t4)

    # carrega yi
    mul  $t3, $t2, $s2
    add  $t3, $t3, $s4
    sll  $t3, $t3, 2
    addu $t4, $s0, $t3
    lwc1 $f6, 0($t4)

    # (x - mx), (y - my)
    sub.s $f20, $f4, $f10
    sub.s $f22, $f6, $f12

    # Sxx += (x-mx)^2
    mul.s $f24, $f20, $f20
    add.s $f14, $f14, $f24

    # Syy += (y-my)^2
    mul.s $f24, $f22, $f22
    add.s $f16, $f16, $f24

    # Sxy += (x-mx)*(y-my)
    mul.s $f24, $f20, $f22
    add.s $f18, $f18, $f24

    addi $t2, $t2, 1 #j++
    j    calc_soma_loop

calc_soma_feita:
    # div = sqrt(Sxx * Syy) em $f22
    mul.s $f22, $f14, $f16
    sqrt.s $f22, $f22

    # evitar div por zero: se div == 0; retorna 0.0
    # porem comparacao com float eh bem engenhoso
    # entao vou transformar em int ai eu comparo, meu problema eh so com o 0 mesmo
    cvt.w.s $f24, $f22
    mfc1   $t5, $f24
    beq    $t5, $zero, div_zero

    div.s $f0, $f18, $f22    # f0 = Sxy / denom = p;
    j      corr_fim

div_zero:
    # resultado = 0.0
    mtc1 $t1, $f0
    cvt.s.w $f0, $f0
    
corr_fim:
    # restaurar registradores pois sao Saveds e retornar
    lw   $ra, 44($sp)
    lw   $s0, 40($sp)
    lw   $s1, 36($sp)
    lw   $s2, 32($sp)
    lw   $s3, 28($sp)
    lw   $s4, 24($sp)
    lw   $s5, 20($sp)
    addi $sp, $sp, 48
    jr   $ra
