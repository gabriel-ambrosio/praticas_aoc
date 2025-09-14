.data
	# ----------------------------------- prompts ----------------------------- #
	msgPergunta: .asciiz "Digite a quantidade de parcelas a serem somadas: "
	msgnInvalido: .asciiz "Erro! o numero de parcelas deve ser pelo menos 1!"
	msgParcelas: .asciiz "Soma de "
	msgFloat: .asciiz " parcelas em float: "
	msgDouble: .asciiz " parcelas em double: "
	msgProximaLinha: .asciiz "\n"
	
	# ------------------------- variaveis auxiliares -------------------------- #
	valor1FLOAT: .float 1.0
	valor1DOUBLE: .double 1.0
	
	
.text

main:
	#print pergunta
	li $v0, 4
	la $a0, msgPergunta
	syscall
	
	#leitura de n
	li $v0, 5
	syscall
	
	li $a1, 1 #armazena 1 em t1
	blt $v0, $a1, nInvalido # checa se n < 1, se for vai pra nInvalido, senao programa segue
	
	#armazena n em t0
	move $a0, $v0
	
	jal harmonica # chama funcao
	
	# encerra programa
	li $v0, 10
	syscall
	
	
	# if n < 1
	nInvalido:
	
	#print erro
	li $v0, 4
	la $a0, msgnInvalido
	syscall
	
	#encerra programa
	li $v0, 10
	syscall
	
	
	
harmonica:

	# guarda 1.0 em f0 (float) e f16(double)
	lwc1 $f0, valor1FLOAT
	ldc1 $f16, valor1DOUBLE
	move $t0, $a0
	
	while:
	bgt $a1, $a0, saida # checa se k = n
	
	# -------------------- float single precision ------------------------------------- #
	
	mtc1 $a1, $f1 # move k(a1) para f1 
	cvt.s.w $f2, $f1 # converte n(int) para float
	
	div.s $f3, $f0, $f2 # divide 1.0 / k.0
	add.s $f4, $f4, $f3 # acumula parcelas em f4
	
	
	# ------------------------ float double precision ----------------------------------- #
	
	mtc1.d $a1, $f6 # move k(a1) para f6 
	cvt.d.w $f8, $f6 # converte n(int) para double
	
	div.d $f10, $f16, $f8 # divide 1.0 / k.0
	add.d $f14, $f14, $f10 # acumula parcelas em f14
	
	
	addi $a1, $a1, 1 # incrementa k
	j while # jump para comeco do loop
	
	#saida do loop
	saida:
	
	# ----------------------------- print float -------------------------- #
	li $v0, 4 # print string
	la $a0, msgParcelas
	syscall
	
	li $v0, 1 # print n
	move $a0, $t0
	syscall
	
	li $v0, 4 # print string
	la $a0, msgFloat
	syscall
	
	mov.s $f12, $f4 # move soma das parcelas float
	li $v0, 2 # imprime a divisao float
	syscall
	
	# ---------------------------- print double -------------------------- #
	
	li $v0, 4 # print pula linha
	la $a0, msgProximaLinha
	syscall 
	
	li $v0, 4 # print string
	la $a0, msgParcelas
	syscall
	
	li $v0, 1 #print n
	move $a0, $t0
	syscall
	
	li $v0, 4 # print string
	la $a0, msgDouble
	syscall
	
	mov.d $f12, $f14 # move soma das parcelas double
	li $v0, 3 # imprime a divisao double
	syscall
	
	jr $ra # retorna