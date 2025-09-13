#Configuracoes do MARS Data Cache 
#     Cache block size (words): 32
#     Cache size (bytes): 1024
#     Placemente Policy: Direct Mapping
#     Block Replacement Policy: LRU

.data
    # matrizes A, B e C (n x n)
    
    # Pelo tamanho da matriz ser 512 a operacao demora MUITO
    n: .word 512
    block_size: .word 16 #tamanho do bloco B
    A: .space 1048576 #512 x 512 x 4 bytes
    B: .space 1048576
    C: .space 1048576
.text
.globl main

main: 
    # inicializa a matriz C com 0
    la $s2, C
    li $t9, 0
    li $t8, 1048576 #tamanho da matriz, ela nao e grande nem pequena ela e enorme aaaaaaaaaaaaah
    
ini_loop:

    sw $zero, 0($s2)
    addi $s2, $s2, 4
    addi $t9, $t9, 4
    blt $t9, $t8, ini_loop
    
    # ponteiros para as matrizes
    la $s0, A
    la $s1, B
    la $s2, C
    lw $s3, n 
    lw $s4, block_size 
    
    # contador
    li $t0, 0 # $t0 = i 
   
ext_i_loop:
    li $t1, 0 # $t1 = j
    
ext_j_loop:
    li $t2, 0 # $t2 = k 
    
ext_k_loop:
    # calcular limites para o bloco i 
    move $t3, $t0, # li (linha interna de i) = i
    add $t7, $t0, $s4 # j + B
    bge $t7, $s3, i_max #if i + B >= n
    move $t7, $t7 #limite = i + B
    j i_limites_prontos

i_max:
    move $t7, $s3 # limite = n
  
i_limites_prontos:

int_i_loop:
    # calcular limites do bloco j
    move $t4, $t1 # lj = j
    add $t8, $t1, $s4 # j + B
    bge $t8, $s3, j_max # if i + B >= n
    move $t8, $t8 #limite = i + B
    j j_limites_prontos
j_max:
    move $t8, $s3 # limite = n

j_limites_prontos:

int_j_loop:
    # calcular C[li][lj]
    mul $t9, $t3, $s3 # $t9 = li * n
    add $t9, $t9, $t2 # (li * n) + k
    sll $t9, $t9, 2   # ((li * n) + k) * 4
    add $t9, $t9, $s2 # $s2 = endereço de C[li][lj]
    lw $s5, 0($t9)    # $s5 = C[li][lj]
    
    # calcular limites para o bloco k
    move $t5, $t2 #lk = k
    add $t6, $t2, $s4 # k + B
    bge $t6, $s3, k_max # if k + B >= n
    move $t6, $t6, #limite = k + B 
    j k_limites_prontos

k_max:
    move $t6, $s3 # limite  = n
 
k_limites_prontos:

int_k_loop:
    # calcular A[li][lk]
    mul $s6, $t3, $s3 # $s6 = li * n
    add $s6, $s6, $t5 # (li * n) + lk
    sll $s6, $s6, 2   # ((li * n) + lk) * 4
    add $s6, $s6, $s0 # $s0 = endereco de A[li][lk]
    lw $s7, 0($s6)    # $s7 =' A[li][lk]
    
    # calcular B[lk][lj]
    mul $s6, $t5, $s3 # $s6 = lk * n
    add $s6, $s6, $t4 # (lk * n) + lj
    sll $s6, $s6, 2   # ((lk * n) +  lj) * 4
    add $s6, $s6, $s1 # $s1 = endereco de B[lk][lj]
    lw $k0, 0($s6)    # $k0 = B[kl][jl]
    
    # multiplicar e acumular
    mul $k1, $s7, $k0  # A[li][lk] * B[lk][lj]
    add $s5, $s5, $k1  # acumular no resultado
    
    # prox kl
    addi $t5, $t5, 1 # kl++
    blt $t5, $t6, int_k_loop
    
    # armazenar resultado em C[il][jl]
    sw $s5, 0($t9)
    
    # prox jl
    addi $t4, $t4, 1   # jl++
    blt $t4, $t8, int_j_loop
    
    # prox il
    addi $t3, $t3, 1   # il++
    blt $t3, $t7, int_i_loop
    
    # prox k (bloco externo)
    add $t2, $t2, $s4  # k += B
    blt $t2, $s3, ext_k_loop
    
    # prox j (bloco externo)
    add $t1, $t1, $s4  # j += B
    blt $t1, $s3, ext_j_loop
    
    # proxi (bloco externo)
    add $t0, $t0, $s4  # i += B
    blt $t0, $s3, ext_i_loop
    
    # Terminar programa
    li $v0, 10
    syscall

 
