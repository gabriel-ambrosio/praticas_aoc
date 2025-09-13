#Configuracoes do MARS Data Cache 
#     Cache block size (words): 32
#     Cache size (bytes): 1024
#     Placemente Policy: Direct Mapping
#     Block Replacement Policy: LRU

.data
    #matrizes A, B e C (n x n)
    
    # Pelo tamanho da matriz ser 512 a operacao demora MUITO
    n: .word 512
    
    A: .space 1048576 #512 x 512 x 4 bytes
    B: .space 1048576
    C: .space 1048576

.text
.globl main

main: 
    #inicializa a matriz C com 0
    la $s2, C
    li $t9, 0
    li $t8, 1048576 #tamanho da matriz, ela nao e grande nem pequena ela e enorme aaaaaaaaaaaaah
    
ini_loop:

    sw $zero, 0($s2)
    addi $s2, $s2, 4
    addi $t9, $t9, 4
    blt $t9, $t8, ini_loop
    
    #ponteiros para as matrizes
    la $s0, A
    la $s1, B
    la $s2, C
    lw $s3, n 
    
    #contador
    li $t0, 0 # $t0 = i 
   
i_loop:
    li $t1, 0 # $t1 = j

j_loop:
     #endereco de C[i][j]
     mul $t4, $t0, $s3 # $t4 = i * n
     add $t4, $t4, $t1 # (i * n) + j
     sll $t4, $t4, 2   # ((i * n) + j) * (2)^2
     add $t4, $t4, $s2 # s2 =  endereco de C[i][j 
	
     li $t5, 0 # soma = 0 
     li $t2, 0 # $t2 = k

k_loop:

    #calcular A[i][k]
    
    mul $t6, $t0, $s3 # $t6 = i * n
    add $t6, $t6, $t2 # (i * n) + k
    sll $t6, $t6, 2   # ((i * n) + k) * 4
    add $t6, $t6, $s0 # $s0 = endereço de A[i][k]
    lw $t7, 0($t6)    # $t7 = A[i][k]
    
    #calcular B[k][j]
    
    mul $t6, $t2, $s3 # $t6 = k * n
    add $t6, $t6, $t1 # (k * n) + j
    sll $t6, $t6, 2   # ((k * n ) + j) * 4
    add $t6, $t6, $s1 # endereço de B[k][j]
    lw $t8, 0($t6)    # $t8 = B[k][j]
    
    #multipicar e caumul
    mul $t9, $t7, $t8 # A[i][k] * B[k][j]
    add $t5, $t5, $t9 # soma += produto
    
    # proximo k
    addi $t2, $t2, 1 # k++
    blt $t2, $s3, k_loop # if k < n
    
    # armazenar resultado em C[i][j]
    sw $t5, 0($t4)
    
    # proximo j
    addi $t1, $t1, 1 #j++
    blt $t1, $s3, j_loop #if j < n
    
    # proximo i
    addi $t0, $t0, 1
    blt $t0, $s3, i_loop
    
    # terminar programa
    li $v0, 10
    syscall
    
    
