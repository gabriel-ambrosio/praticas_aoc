.data
	msg1: .asciiz "Digite um número de pontos entre 10 e 50: "
	msgErro: .asciiz "Valor invalido! Tente novamente.\n\n"
	msgTeste: .asciiz "Número de pontos: "
	msgPontos: .asciiz "\nPontos gerados: \n"
	msgVirgula: .asciiz ", "
	msg1Parenteses: .asciiz "("
	msg2Parenteses: .asciiz ")\n"
	msgCoeficientes: .asciiz " Coeficientes de reta Y = A.X + B: \n"
	msgA: .asciiz "A = "
	msgB: .asciiz "\nB = "
	
	.align 2
	pontos: .space 400 # (100 * 4bytes) Serve para reservar até 100 espaços de float no vetor (50 pontos, com 2 coordenadas cada)
	n: .word 0 # Quantidade de pontos
	val0: .float 0.0
	A: .float 0.0	# Coeficientes calculados
	B: .float 0.0
	
	
.text
.globl main
main:
	li $v0, 4		# Imprime msg1
	la $a0, msg1
	syscall
	
	li $v0, 5		# Lê um valor inteiro
	syscall
	move $t0, $v0		# Armazena temporariamente em t0
	
	li $t1, 10		# Verifica se n < 10
	blt $t0, $t1, invalido		
	
	li $t1, 50		# Verifica se n > 50
	bgt $t0, $t1, invalido
	
	j valido
	
invalido:
	li $v0, 4
	la $a0, msgErro		# Imprime msgErro
	syscall

	j main
	
valido:
	sw $t0, n		# Guarda o valor digitado pelo usuário em n
	
	li $v0, 4		# Verifica se o número de pontos foi validado, e imprime ele
	la $a0, msgTeste
	syscall
	
	li $v0, 1		
	move $a0, $t0
	syscall
	
	li $t0, 0		# Contador i = 0
	lw $t1, n		# Carrega n em t1
	li $t2, 2		# Carrega o valor 2	
	mul $t3, $t2, $t1 	# Calcula (2 * n) (número total de coordenadas)
	
	la $t4, pontos		# Endereço base do vetor
	
loopPreencher: 
	bge $t0, $t3, imprimePontos	# Condição de parada do loop (quando i >= 2 * n)
	
	li $v0, 42		# Syscall para gerar um número inteiro aleatório
	li $a1, 100		# Intervalo de 0 a 99
	syscall		
	
	mtc1 $a0, $f6		# Move o inteiro para registrator de ponto flutuante
	cvt.s.w $f6, $f6	# Converte para float
	s.s $f6, 0($t4)		# Armazena esse valor na posição atual do vetor
	
	addi $t4, $t4, 4	# Avança para a próxima posição de memória (4 bytes = 1 word)
	addi $t0, $t0, 1	# i++
	
	j loopPreencher
	
		
imprimePontos:
	li $v0, 4
	la $a0, msgPontos	# Imprime msgPontos
	syscall
	
	la $t4, pontos		# Endereço base do vetor pontos
	lw $t1, n		# Carrega n em t1
	li $t0, 0		# i = 0
	
loopImprimePontos:
	bge $t0, $t1, regressaoLinear	# Condição de parada do loop (quando i >= n)

	li $v0, 4			# "("
	la $a0, msg1Parenteses
	syscall
	
	li $v0, 2			# "xi"
	l.s $f12, 0($t4)
	syscall
	
	li $v0, 4			# ", "
	la $a0, msgVirgula
	syscall
	
	li $v0, 2			# "yi"
	l.s $f12, 4($t4)	
	syscall
	
	li $v0, 4			# ")\n"
	la $a0, msg2Parenteses
	syscall		
	
	addi $t4, $t4, 8		# Avança o ponteiro do vetor para o próximo xi
	addi $t0, $t0, 1		# i++
	
	j loopImprimePontos

regressaoLinear:
	la $t4, pontos		# Endereço base do vetor pontos

	l.s $f0, val0		# Sx
	l.s $f1, val0		# Sy
	l.s $f2, val0		# Sxx
	l.s $f3, val0		# Sxy
	li $t0, 0		# Contador i = 0
	
	
loopSomas:
	bge $t0, $t3 , imprimeCoeficientes	# Condição de parada (i >= 2 * n)
	
	l.s $f4, 0($t4)		# Guarda em f4 o valor xi
	l.s $f5, 4($t4)		# Guarda em f5 o valor yi
	
	add.s $f0, $f0, $f4	# Sx
		
	add.s $f1, $f1, $f5	# Sy
							
	mul.s $f25, $f4, $f4 	# Sxx
	add.s $f2, $f2, $f25	
	
	mul.s $f26, $f4, $f5	# Sxy
	add.s $f3, $f3, $f26	
	
	addi $t0, $t0, 2	# i += 2
	addi $t4, $t4, 8	# Avança o ponteiro em 8 bytes (próximo ponto com coordenadas (xi,yi))
	
	j loopSomas
	
imprimeCoeficientes:
	l.s $f10, A		# Carrega os coeficientes A e B em registradores (inicialmente valem 0)
	l.s $f11, B
				
	mtc1 $t1, $f30
	cvt.s.w $f30, $f30
	
	mul.s $f20, $f30, $f3 	# n * Sxy
	mul.s $f21, $f0, $f1	# Sx * Sy
	mul.s $f22, $f30, $f2	# n * Sxx
	mul.s $f23, $f0, $f0	# Sx * Sx
	sub.s $f24, $f20, $f21	# nSxy - SxSy
	sub.s $f25, $f22, $f23	# nSxx - (Sx)^2
	div.s $f26, $f24, $f25	# Coeficiente A
	
	mul.s $f20, $f26, $f0	# A * Sx
	sub.s $f21, $f1, $f20	# Sy - ASx
	div.s $f22, $f21, $f30	# Coeficiente B
	
	li $v0, 4
	la $a0, msgCoeficientes	# Imprime msgCoeficientes
	syscall
	
	li $v0, 4
	la $a0, msgA		# "A = "
	syscall
	
	li $v0, 2
	mov.s $f12, $f26	# Imprime o valor de A
	syscall
	
	li $v0, 4
	la $a0, msgB		# "B = "
	syscall
	
	li $v0, 2
	mov.s $f12, $f22	# Imprime o valor de B
	syscall
	
	li $v0, 10		# Encerra o programa
	syscall
	

	
