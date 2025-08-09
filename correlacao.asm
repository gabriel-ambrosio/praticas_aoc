.data
# matriz com 6 alimentos x 4 nutrientes (floats)
# matriz retirada da questao
matriz: .float 239.0, 49.0, 1.2, 8.0      # pao
        .float 354.0, 77.0, 1.7, 7.6      # arroz
        .float 90.0, 20.0, 0.3, 1.0       # banana
        .float 52.0, 12.0, 0.3, 0.3       # maca
        .float 32.0, 7.0, 0.3, 2.4        # couve flor
        .float 22.0, 4.0, 0.2, 1.0        # tomate

n_alimentos:   .word 6       # número de linhas da matriz
n_nutrientes:  .word 4       # número de colunas da matriz
colunaX:       .word 0       # exemplo: calorias
colunaY:       .word 1       # exemplo: glicídios

zero:          .float 0.0    # constante 0 float

msg_result:    .asciiz "Correlacao segundo a matriz: "

.text
main:
    # carrega parametros
    lw $t0, n_alimentos       # numero de alimentos (n)
    lw $t1, n_nutrientes      # numero de nutrientes
    lw $t2, colunaX           # indice da coluna X
    lw $t3, colunaY           # indice da coluna Y
    la $t4, matriz            # endereco base da matriz

    # Inicializar somas
    l.s $f0, zero             # somaX
    l.s $f2, zero             # somaY
    li $t5, 0                 # inicia o i = 0

# loop para calcular as medias xbarrado e ybarrado
loop_somas:
    beq $t5, $t0, fim_somas   # se i == n, sai do loop

    # carregar xi
    mul $t6, $t5, $t1         # i * n_nutrientes
    add $t6, $t6, $t2         # + colunaX
    sll $t6, $t6, 2           # * 4 bytes
    add $t7, $t4, $t6
    l.s $f4, 0($t7)           # carrega xi
    add.s $f0, $f0, $f4       # somaX = somaX + xi

    # carregar yi
    mul $t6, $t5, $t1
    add $t6, $t6, $t3
    sll $t6, $t6, 2
    add $t7, $t4, $t6
    l.s $f6, 0($t7)           # carrega yi
    add.s $f2, $f2, $f6       # somaY = somaY + yi

    addi $t5, $t5, 1
    j loop_somas

fim_somas:
    # calcular medias: mediaX = somaX / n, mediaY = somaY / n
    mtc1 $t0, $f8             # mover n para FP
    cvt.s.w $f8, $f8          # converter para float
    div.s $f10, $f0, $f8      # mediaX
    div.s $f12, $f2, $f8      # mediaY

    # inicializar Sxx, Syy e Sxy
    l.s $f14, zero            # Sxx
    l.s $f16, zero            # Syy
    l.s $f18, zero            # Sxy
    li $t5, 0                 # i = 0

# loop que calcular s sxx syy sxy
loop_var:
    beq $t5, $t0, fim_var

    # carregar x_i
    mul $t6, $t5, $t1
    add $t6, $t6, $t2
    sll $t6, $t6, 2
    add $t7, $t4, $t6
    l.s $f4, 0($t7)

    # carregar y_i
    mul $t6, $t5, $t1
    add $t6, $t6, $t3
    sll $t6, $t6, 2
    add $t7, $t4, $t6
    l.s $f6, 0($t7)

    # calcular (x - mediaX) e (y - mediaY)
    sub.s $f20, $f4, $f10
    sub.s $f22, $f6, $f12

    #  sxx = sxx + (x - mediaX)^2
    mul.s $f24, $f20, $f20
    add.s $f14, $f14, $f24

    # syy = syy +  (y - mediaY)^2
    mul.s $f26, $f22, $f22
    add.s $f16, $f16, $f26

    # sxy = sxy + (x - mediaX)*(y - mediaY)
    mul.s $f28, $f20, $f22
    add.s $f18, $f18, $f28

    addi $t5, $t5, 1
    j loop_var

fim_var:
    # calcular correlacao = Sxy / sqrt(sxx * syy)
    mul.s $f30, $f14, $f16
    sqrt.s $f30, $f30
    div.s $f0, $f18, $f30     # resultado em $f0

    # imprime resultado
    li $v0, 4
    la $a0, msg_result
    syscall

    li $v0, 2
    mov.s $f12, $f0
    syscall

    # encerra o programa
    li $v0, 10
    syscall
