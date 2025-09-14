.data
  pergunta:   .asciiz "Digite o valor de n: "
  resultado: .asciiz "phi(n) = "
.text
.globl main


main:

  li $v0, 4            
  la $a0, pergunta   
  syscall

  li $v0, 5            
  syscall
 

  move $a0, $v0         
  jal phi
 
  move $t0, $v0      
  
  li $v0, 4             
  la $a0, resultado
  syscall


  li $v0, 1             
  move $a0, $t0 
  syscall

 
  li $v0, 10            
  syscall
phi:
  move $t4, $ra      
  li $t0, 1
  li $t1, 0
  move $s0, $a0
phi_loop:
  bgt $t0, $s0, phi_fim
  move $a0, $s0
  move $a1, $t0
  jal mdc            
  li $t2, 1
  bne $v0, $t2, pula
  addi $t1, $t1, 1
pula:
  addi $t0, $t0, 1
  j phi_loop

phi_fim:
  move $v0, $t1
  move $ra, $t4        
  jr $ra             
mdc:
mdc_loop:
	beq $a1, $zero, mdc_fim   # while, faz o loop ate b == 0
	move $t5, $a1             # alg de euclides
	div $a0, $a1           
	mfhi $a1                   
	move $a0, $t5             
	j mdc_loop
	
mdc_fim:
	move $v0, $a0             # retorna a
	jr $ra
	
