.data
msg0: .asciiz "0\n"
msg1: .asciiz "1\n"

.text
.globl main

main:
	
	jal getchar
	
	move $a0, $v0
	
	jal is_digit
	
	beq $v0, $zero, print_zero
	la $a0, msg1
	jal print_string
	j fim
	
	

















getchar:
	lw $v0, 0xffff0000 #carrega em v0 a entrada do ususario
	andi $v0, $v0, 0x01 #verifica o ultimo bit da palavra, caso o dado não esteja pronto, o valor do ultimo bit deve ser zero
	beq $v0, $zero, getchar #caso a palavra não ternha sido lida, chama a função novamente
	lw $v0, 0xffff0004  #guarda a palavra lida do e/s
	jr $ra
	
	



print_string: # $a0: endereço da string
    li   $t0, 0xffff0008
    j    ps_cond
    
   
   

ps_loop:
    lw   $v0, ($t0)
    andi $v0, $v0, 0x01
    beq  $v0, $zero, ps_loop
    lbu  $t1, ($a0)
    beq  $t1, $zero, ps_fim
    sb   $t1, 4($t0)
    addi $a0, $a0, 1
    



ps_cond:
    lbu  $t1, ($a0)
    bne  $t1, $zero, ps_loop

ps_fim:
    jr   $ra




is_digit:
 	addi $t0, $zero, 47 #'0'
 	addi $t1, $zero, 56 #'9'
 	blt  $a0, $t0, not_digit
 	bgt  $a0, $t1, not_digit
 	li $v0, 1
 	jr $ra

not_digit:
	li $v0, 0
	jr $ra
	
print_zero:
	la $a0, msg0
	jal print_string


fim: 
	li $v0, 10
	syscall
	
	
	
