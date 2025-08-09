.data
	msg1: .asciiz "Digite o valor do coeficiente a: "
	msg2: .asciiz "Digite o valor do coeficiente b: "
	msg3: .asciiz "Digite o valor do coeficiente c: "
	msg4: .asciiz "Raízes da equação de segundo grau dada: \n"
	msgErro: .asciiz "Sem raizes para a equação."
	msgr1: .asciiz "R1 = "
	msgr2: .asciiz "\nR2 = "
	
	num1: .float 0.0	# Coeficientes 'a', 'b' e 'c' inicialmente zerados
	num2: .float 0.0 
	num3: .float 0.0
	
	val4: .float 4.0
	val0: .float 0.0
	val2: .float 2.0

	fator: .float 10.0

.text
.globl main
main:
	li $v0, 4		# Imprime msg1
	la $a0, msg1
	syscall
	
	li $v0, 6		# Armazena o valor do coeficiente 'a'
	syscall
	s.s $f0, num1
		
	li $v0, 4		# Imprime msg2
	la $a0, msg2
	syscall
	
	li $v0, 6		# Armazena o valor do coeficiente 'b'
	syscall
	s.s $f0, num2
	
	li $v0, 4		# Imprime msg3
	la $a0, msg3
	syscall
	
	li $v0, 6		# Armazena o valor do coeficiente 'c'
	syscall
	s.s $f0, num3
	
	l.s $f1, num1		# Carrega o coef. 'a' em f1
	l.s $f2, num2		# Carrega o coef. 'b' em f2
	l.s $f3, num3		# Carrega o coef. 'c' em f3
	
	mul.s $f10, $f2, $f2	# Calcula (b ^ 2) e armazena em f10
	
	l.s $f11, val4		# Guarda o valor 4 em f11
	mul.s $f12, $f1, $f3	# Guarda (a * c) em f12
	mul.s $f13, $f11, $f12	# Guarda 4 * (a * c) em f13
	
	sub.s $f20, $f10, $f13	# Guarda o delta em f20
	
	l.s $f0, val0		# Carrega o valor 0
	c.lt.s $f20, $f0	# delta < 0?
	bc1t semRaizes
	
	sqrt.s $f21, $f20	# Guarda raiz quadrada de delta em f21
	
	l.s $f22, fator
	mul.s $f23, $f22, $f12	# Multiplica o ac em 10 vezes
	
	c.lt.s $f23, $f10
	bc1t cancelamento	
	
	neg.s $f4, $f2		# Guarda (-b) em f4	
	add.s $f15, $f4, $f21	# Calcula (-b + raiz (delta))
	l.s $f0, val2		# Carrega o valor 2
	mul.s $f6, $f0, $f1	# Calcula (2 * a)
	div.s $f7, $f15, $f6	# Raiz r1 tradicional
	
	sub.s $f16, $f4, $f21	# Calcula (-b - raiz(delta))
	div.s $f8, $f16, $f6 	# Raiz r2 tradicional
	
	j imprime
	
cancelamento:
	l.s $f0, val0
	c.lt.s $f2, $f0
	bc1f bPositivo
	
	neg.s $f4, $f2		# Guarda (-b) em f4	
	add.s $f5, $f4, $f21	# Calcula (-b + raiz (delta))
	l.s $f0, val2		# Carrega o valor 2
	mul.s $f6, $f0, $f1	# Calcula (2 * a)
	div.s $f7, $f5, $f6	# Raiz r1 tradicional
	
	mul.s $f10, $f0, $f3	# Calcula (2 * c)
	div.s $f8, $f10, $f5	# Raiz r2 segura
				
	j imprime
	
bPositivo:
	l.s $f0, val2
	
	neg.s $f4, $f2		# Guarda (-b) em f4
	sub.s $f5, $f4, $f21	# Calcula (-b - raiz(delta))
	mul.s $f10, $f0, $f3	# Calcula (2 * c)
	div.s $f7, $f10, $f5	# Raiz r1 segura
	
	mul.s $f6, $f0, $f1	# Calcula (2 * a)
	div.s $f8, $f5, $f6	# Raiz r2 tradicional 	
	
imprime:
	li $v0, 4
	la $a0, msg4		# Imprime msg4
	syscall
	
	li $v0, 4		
	la $a0, msgr1		# "R1 = "
	syscall
	
	li $v0, 2
	mov.s $f12, $f7
	syscall			# Imprime r1
	
	li $v0, 4
	la, $a0, msgr2		# "R2 = "
	syscall
	
	li $v0, 2
	mov.s $f12, $f8		# Imprime r2
	syscall
	
j fim

semRaizes:
	li $v0, 4
	la $a0, msgErro
	syscall
					
fim:
	li $v0, 10		# Encerramento do programa
	syscall	

