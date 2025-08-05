.data
	mensagem: .asciiz "Digite a string: "
	frase: .space 1001
	saida1: .asciiz "Matriz zig-zag ("
	saida2: .asciiz "x"
	saida3: .asciiz "):"
	quebraLinha: .asciiz "\n"
	espaco: .byte ' '

.text

main:
	# impressao msg
	li $v0, 4
	la $a0, mensagem
	syscall
	
	# scan frase
	li $v0, 8
	la $a0, frase
	li $a1, 1001
	syscall
	
	move $a1, $a0 # guarda frase em a1
	
	jal strlen # achar strlen
	
	move $a0, $v0 # strlen v0 -> a0
	move $s0, $v0 # strlen v0 -> s0
	jal elemsPorLinha # achar n
	
	move $a3, $v0 # n v0 -> a3
	
	mflo $a0 # a0 = n * n
	li $v0, 9 # alloc n * n
	syscall
	
	move $a2, $v0 # ponteiro base v0 -> a2
	
	# chama funcoes
	jal preencheMatriz
	jal imprimeMatriz

	# encerrar programa	
	li $v0, 10
	syscall
	
	
	 
strlen:
	li $v0, 0      # contador
	move $t0, $a0 #string a0 -> t0
	
	loop1:
		lb $t1, 0($t0)      # carrega 1 byte
		beq $t1, $zero, fim1 # se '\0', para
    		addi $v0, $v0, 1    # add contador
    		addi $t0, $t0, 1    # próximo byte
    		j loop1
	
	fim1:
		subi $v0, $v0, 1 # subtrai '/n'
		jr $ra # retorna
		
		
elemsPorLinha:

	li $v0, 0  # contador
	move $t0, $a0 # strlen a0 -> t0
	
	
	loop2:
		mul $t1, $v0, $v0 # t1 = n * n
		bge $t1, $t0, fim2 # se n^2 > strlen, para 
		addi $v0, $v0, 1 # add contador
		j loop2
		
	fim2:
		jr $ra # retorna

				
preencheMatriz:

	li $t0, 0 # contador linhas
	li $t1, 0 # elem
	
	loop3:
		bge $t1, $a0, fim3 # elem >= n * n
		bge $t1, $s0, padding # elem >= strlen && elem < n^2
		li $t3, 0 # iterador elem na linha
		andi $t2, $t0, 1 # se par(0, 2, 4... t2 = 0) se impar(1, 3, 5... t2 != 0)
		beq $t2, $zero, normal # se t2 = 0 esquerda -> direita
		
		inverso: # direita -> esquerda
		bge $t3, $a3, aumentaLinha # checa se linha foi preenchida
		 	
		# pega pos elem	(n * linha + (n - 1 - elemL)) 	
		sub $t4, $a3, 1 # n - 1
		sub $t4, $t4, $t3 # n - 1 - elemL
		mul $t5, $t0, $a3 # n * linha
		add $t4, $t4, $t5  # n * linha + n - 1 - elemL
		
		add $t4, $a2, $t4 # ajusta a pos da matriz
		lb $t6, 0($a1) # carrega elemento em a1
		sb $t6, 0($t4) # guarda elem em a1 na pos de mem t4
		 	
		addi $t1, $t1, 1 # aumenta iterador global
		addi $a1, $a1, 1 # proximo elem da frase
		addi $t3, $t3, 1 # aumenta iterador linha
		j inverso # segue loop
		  
	normal: # esquerda -> direita
		bge $t3, $a3, aumentaLinha # checa se linha foi preenchida
		 	 	
		add $t4, $t1, 0 # pega pos elem
		add $t4, $a2, $t4 # ajusta a pos da matriz
		lb $t6, 0($a1) # carrega elemento em a1
		sb $t6, 0($t4) # guarda elem em a1 na pos de mem t4
		 	
		addi $t1, $t1, 1 # aumenta iterador global
		addi $a1, $a1, 1 # proximo elem da frase
		addi $t3, $t3, 1 # aumenta iterador linha
		j normal # segue loop
		 
	aumentaLinha:
		 addi $t0, $t0, 1 # aumenta linha
		 j loop3 # volta para inicio do loop
		 
	padding:
		bge $t1, $a0, fim3 # se elem >= n^2 termina
		add $t4, $t1, 0 # pega pos elem
		add $t4, $a2, $t4 # ajusta a pos da matriz
		la $t6, espaco # load do padding
		sb $t6, 0($t4) # faz padding na pos de mem t4
		 	
		addi $t1, $t1, 1 # aumenta iterador global
		addi $t3, $t3, 1 # aumenta iterador linha
		j padding # segue loop
		 
	fim3:
		jr $ra # retorna para main
	
			
imprimeMatriz:
	
	move $t0, $a0 # t0 = n * n
	li $t1, 0 # elem
	li $t2, 0 # elem linha
	
	#print strings
	li $v0, 4
	la $a0, quebraLinha
	syscall # print "\n"
	
	la $a0, saida1
	syscall # print "Matriz zig-zag("
	
	li $v0, 1
	move $a0, $a3
	syscall # print "n"
	
	li $v0, 4
	la $a0, saida2
	syscall # print "x"
	
	li $v0, 1
	move $a0, $a3
	syscall # print "n"
	
	li $v0, 4
	la $a0, saida3
	syscall #print "):"
	
	la $a0, quebraLinha
	syscall # print "\n"	
	
	#print matriz
	loop4:
		beq $t1, $t0, fim4 # se elem = n^2 finaliza
		li $v0, 11 # print caractere
		
		add $t4, $t1, 0 # pega pos elem
		add $t4, $a2, $t4 # ajusta a pos da matriz
		lb $a0, 0($t4) # load elem em t1 pos mem em a0
		syscall # print elem
		
		addi $t1, $t1, 1 # aumenta elem
		addi $t2, $t2, 1 # aumente elem linha
		beq $t2, $a3, pulaLinha # se elem linha = n, quebra linha
		j loop4 # segue loop
	
	pulaLinha:
		li $t2, 0 # zera elem linha
		li $v0, 4 # print string
		la $a0, quebraLinha
		syscall # print "\n"
		j loop4 # segue loop
		
	fim4:
		jr $ra # retorna main
	
		 	 
		
	
