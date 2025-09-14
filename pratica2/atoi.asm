.data
	# ----------------------------------- prompts ----------------------------- #
	msgPergunta: .asciiz "Digite a string a ser convertida: "
	msgStrInvalida: .asciiz "A string enviada nao pode ser convertida para algarismos inteiros ou esta fora do intervalo aceito [0, 4294967294]"
	msgResultado: .asciiz "A string convertida e: "
	msgPulaLinha: .asciiz "\n"
	
.text

main:

	# OBS: o maior valor unsigned int que pode ser representado em 32 bits é 4294967295
	# mas em bits ele é exatamente igual ao -1 e como o branch compara bit a bit nao é possivel diferenciar os dois
	# assim o maximo vai ate 4294967294 
	# e como o programa nao deve se preocupar com numeros negativos, comeca em 0
	# entao o intervalo de valores a serem convertidos que o programa aceitara vai ser [0, 4294967294]
	# se for diferente disso constara como string invalida
	
	# aloca buffer para string
	li $v0, 9
	li $a0, 11
	syscall
	
	# ponteiro em t0
	move $t0, $v0
	
	# pergunta string
	li $v0, 4
	la $a0, msgPergunta
	syscall
	
	# le string
	li $v0, 8
	move $a0, $t0
	li $a1, 11
	syscall
	
	jal strlen # achar strlen
	
	jal atoi # converte string para int
	
	move $t0, $v0 # resultado em int v0 -> t0
	
	# pula linha
	li $v0, 4
	la $a0, msgPulaLinha
	syscall
	
	beq $t0, -1, resInvalido # checa se o resultado e invalido(-1)
	
	# print string de resultado
	li $v0, 4
	la $a0, msgResultado
	syscall
	
	# print resultado da conversao em int
	li $v0, 36 # int unsigned
	move $a0, $t0
	syscall
	
	# finaliza programa
	li $v0, 10
	syscall
	
	
	resInvalido:
		# print msg de string invalida
		li $v0, 4
		la $a0, msgStrInvalida
		syscall
		
		# encerra programa
		li $v0, 10
		syscall
		
	
	
	
	
strlen:
	move $a1, $zero      # contador
	move $t0, $a0  #string a0 -> t0
	
	loopSTRLEN:
		lb $t1, 0($t0)      # carrega 1 byte
		beq $t1, 10, fimSTRLEN # 10 equivale a \n em ascii
		beq $t1, $zero, fimSTRLEN # se '\0', para
    		addi $a1, $a1, 1    # add contador
    		addi $t0, $t0, 1    # próximo byte
    		j loopSTRLEN
	
	fimSTRLEN:
		move $a0, $t0 # guarda  endereco de NULL (ou '\n) em a0
		jr $ra # retorna
		

atoi:
	
	move $v0, $zero # acumulador
	move $t0, $a0 # guarda o ponteiro em t0
	move $t1, $zero # iterador do loop
	
	carregaProxByte:
		beq $t1, $a1, fimATOI # se iteracao = strlen, finaliza
		
		subi $t0, $t0, 1 # volta 1 byte
		lb $t2, 0($t0) # carrega 1 byte
		
		# checa se esta no intervalo valido ( 48 -> 57 | 0 -> 9)
		bgt $t2, 57, valorInvalido
		blt $t2, 48, valorInvalido
		
		subi $t2, $t2, 48 # 48 equivale a 0 em ascii
		j exp10 # pega o o multiplicador da base equivalente a pos na string(unidade = 1, dezena = 10, centena = 100, etc) 
		
	atualizaAcc:
		multu $t2, $t3 # multiplica pela pos na string (unidade, dezena, centena, etc), unsigned para intervalo maior
		mflo $t2 # volta o resultado da mult para t2
		
		# se existe valor no hi, passou do intervalo aceito
		mfhi $t6
		bgt $t6, $zero, valorInvalido
		
		beq $t2, 4000000000, pertoLimite # valida se vai estar no intervalo valido perto do limite
		addu $v0, $v0, $t2 # acumula em v0 (unsigned para intervalo maior)
		addi $t1, $t1, 1 # incrementa iterador do loop
		j carregaProxByte
		
	pertoLimite:
		bge $v0, 294967295, valorInvalido # estoura o maior valor valido
		addu $v0, $v0, $t2 # acumula em v0 (unsigned para intervalo maior)
		addi $t1, $t1, 1 # incrementa iterador do loop
		j carregaProxByte
		
		
	exp10:
		li $t5, 10 # guarda 10 em t5 (multiplicador)
		li $t3, 1 # acc, comeca como 1(10^0)
		move $t4, $zero # it do loop de exp
		
		loopEXP10:
			beq $t4, $t1, fimEXP10 # se iteracao = igual pos na string finaliza
			multu $t3, $t5 # multiplica por 10 (unsigned para intervalo maior)
			mflo $t3 # volta o resultado da mult para t3
			addi $t4, $t4, 1 # incrementa iterador
			j loopEXP10
			
		fimEXP10:
			j atualizaAcc
			
		
	valorInvalido:
		li $v0, -1 # define o valor final como -1
		j fimATOI
	
	fimATOI:
		jr $ra	
	
