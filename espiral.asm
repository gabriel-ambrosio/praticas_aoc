.data
prompt:     .asciiz "Digite a string de entrada: "
newline:    .asciiz "\n"
matriz_print: .asciiz "\nSaida: Matriz espiral:\n"

# entrada da string
string:     .space 100     
# espaco para matriz 
matriz:     .space 144

.text
.globl main

main:
    
    li   $v0, 4
    la   $a0, prompt
    syscall

    li   $v0, 8
    la   $a0, string
    li   $a1, 100
    syscall

    
    la   $t0, string
find_newline:
    lb   $t1, 0($t0)
    beq  $t1, 10, newline_to_0
    beq  $t1, $zero, count_start
    addi $t0, $t0, 1
    j    find_newline
newline_to_0:
    sb   $zero, 0($t0)

count_start:
    
    la   $t0, string
    li   $s0, 0         
count_len_loop:
    lb   $t1, 0($t0)
    beq  $t1, $zero, end_count
    addi $s0, $s0, 1
    addi $t0, $t0, 1
    j    count_len_loop
    
    
end_count:
    li   $s1, 1         
matrix_size:
    mul  $t2, $s1, $s1
    bge  $t2, $s0, end_calc_size
    addi $s1, $s1, 1
    j    matrix_size
end_calc_size:

    
    la   $s2, string    # ponteiro para a string
    la   $s3, matriz    # ponteiro para a matriz
    li   $s4, 0         # verifica fim da string

    li   $t5, 0         # cima -> 0
    li   $t6, 0         # esquerda -> 0
    move $t7, $s1
    addi $t7, $t7, -1   # baixo
    move $t8, $s1
    addi $t8, $t8, -1   # direita


fill_spiral_loop:
    bgt  $t5, $t7, print_matrix_entry
    bgt  $t6, $t8, print_matrix_entry

    # parcorre a string esquerda -> direita
    move $t0, $t6       
fill_top_loop:
    # movimentacao na linha de topo da matriz, percorre a direita ->
    mul  $t1, $t5, $s1
    add  $t1, $t1, $t0
    add  $t1, $t1, $s3   
    jal  get_next_char   # Pega o caractere da string 
    sb   $v0, 0($t1)     # Armazena o caractere da string na matriz

    addi $t0, $t0, 1
    ble  $t0, $t8, fill_top_loop
    addi $t5, $t5, 1    # incrementa a direita

    # Desce na matriz, quando chega na ultima coluna
    move $t0, $t5       
fill_right_loop:
    # percorre a matriz para baixo a partir da ultima coluna
    mul  $t1, $t0, $s1
    add  $t1, $t1, $t8
    add  $t1, $t1, $s3   
    jal  get_next_char
    sb   $v0, 0($t1) #armazena o caractere da string na matriz

    addi $t0, $t0, 1
    ble  $t0, $t7, fill_right_loop
    addi $t8, $t8, -1   #"encolhe" a matriz espiral

    # percorre a matriz para a esquerda
    bgt  $t5, $t7, fill_left_entry
    move $t0, $t8       
fill_bottom_loop:
    # preenche a ultima linha para a esquerda <-
    mul  $t1, $t7, $s1
    add  $t1, $t1, $t0
    add  $t1, $t1, $s3   
    jal  get_next_char
    sb   $v0, 0($t1)

    addi $t0, $t0, -1
    bge  $t0, $t6, fill_bottom_loop
    addi $t7, $t7, -1   #"encolhe" as linhas da matriz

fill_left_entry:
    # percorre a matriz subindo
    bgt  $t6, $t8, fill_spiral_loop
    move $t0, $t7       # i = bottom
fill_left_loop:
    # preenche a primeira coluna da matriz na vertical para cima
    mul  $t1, $t0, $s1
    add  $t1, $t1, $t6
    add  $t1, $t1, $s3   
    jal  get_next_char
    sb   $v0, 0($t1)

    addi $t0, $t0, -1
    bge  $t0, $t5, fill_left_loop
    addi $t6, $t6, 1    #"encolhe" as colunas da matriz

    j    fill_spiral_loop


get_next_char:
#pega o proximo caractere da string
    beq  $s4, 1, return_space

    lb   $t2, 0($s2)
    beq  $t2, $zero, flag_space
    
    move $v0, $t2
    addi $s2, $s2, 1
    jr   $ra
flag_space:
#condicional para verificar se é um espaço
    li   $s4, 1
return_space:
#reotrna que o proximo caractere é um espaço
    li   $v0, ' '
    jr   $ra



print_matrix_entry:
#inicializa a impressao da matriz
    li   $v0, 4
    la   $a0, matriz_print
    syscall

    li   $t0, 0 # linhas
print_row_loop:
    li   $t1, 0 # colunas
print_col_loop:
#cria os offsets e printa as colunas e linhas da matriz
    mul  $t2, $t0, $s1
    add  $t2, $t2, $t1
    add  $t2, $s3, $t2
    
    lb   $a0, 0($t2) #printa se for caractere
    li   $v0, 11
    syscall

    li   $a0, ' ' #printa se for espaco
    li   $v0, 11
    syscall

    addi $t1, $t1, 1
    blt  $t1, $s1, print_col_loop #percorre todas as colunas disponiveis, respeitando o encolhimento da matriz

    li   $v0, 4
    la   $a0, newline
    syscall

    addi $t0, $t0, 1
    blt  $t0, $s1, print_row_loop #percorre todas as colunas, respeitando o encolhimento da matriz

    li   $v0, 10
    syscall
