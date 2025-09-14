.data
	tabuleiroVisivel: .space 100		# Parte visual do tabuleiro, reserva as células de 10x10 em um array de 100 espaços
	tabuleiroLogico: .space 100		# Parte lógica do tabuleiro
	novaLinha: .asciiz "\n"			# Pula a linha
	barra: .asciiz "  |  "			# Espaço entre os caracteres
	entrada: .asciiz "\nEnter (x, y):\n"
	espaco: .asciiz "  "
	erroInvalido: .asciiz "Entrada inválida! Tente novamente\n\n"
	msgVitoria: .asciiz "\nParabens, voce venceu!\n"
	msgDerrota: .asciiz "\nBOOOOM! Voce perdeu!\n"
	
.text

.globl main

main:
	jal setTabuleiro		# Preparação do tabuleiro
	jal jogaMinas
	jal contaMinas
	jal controlaJogo		# Passa o controle para a controlaJogo após a primeira execução
	
setTabuleiro:
	li $t0, 0			# Indice i = 0
	li $t3, 0
	
	la $t1, tabuleiroLogico		# Carrega o endereço base do tabuleiro lógico em $t1
	la $t2, tabuleiroVisivel	# Carrega o endereço base do tabuleiro visivel em $t2
				
	j loopIniciarTabuleiro		# Entra para o loop que preenche o tabuleiro
	
  loopIniciarTabuleiro:	
	bge $t0, 100, fimLoopIniciar	# Condição de parada
	
	add $t4, $t1, $t0		# Calcula o endereço atual do lógico + i
	sb $t3, 0($t4)			# Salva o caractere 'O' na memória de forma contínua
	
	add $t5, $t2, $t0		# Calcula o endereço atual do visível + i
	sb $t3, 0($t5)
	
	addi $t0, $t0, 1		# i = i + 1
	
	j loopIniciarTabuleiro
	
  fimLoopIniciar:
	jr $ra				# Retorna para onde a função foi chamada
	
showTabuleiro:
        la $s0, tabuleiroLogico        	 # Carrega endereço base do LÓGICO em $s0 (registrador salvo)
        la $s1, tabuleiroVisivel     	 # Carrega endereço base do VISÍVEL em $s1 (registrador salvo)
        li $t1, 0                      	 # i = 0 (linhas)
	

  loopLinhas:
    	bge $t1, 10, fimShow

    	li $t2, 0              	     	 # j = 0 (colunas)

  loopColunas:    
        bge $t2, 10, proxLinha
    
   
        li $t3, 10		        # Calcula o índice 
        mult $t1, $t3
        mflo $t3
        add $t4, $t3, $t2              	# Armazena em $t4

        add $t5, $s1, $t4      	        # Endereço da célula em tabuleiroVisivel
        lb $t6, 0($t5)      	    	# Carrega o estado da célula (0 = oculto, 1 = revelado) em $t6

        bne $t6, 0, celulaRevelada      # Se n for 0, pula para a função que trata do estado

        li $a0, '_'			# Se a célula está oculta, imprime '_'
        li $v0, 11
        syscall
        
        j fimDaCelula                # Pula para o final da lógica da célula

  celulaRevelada:
        add $t5, $s0, $t4     	     	# Endereço da célula em tabuleiroLogico
        lb $a0, 0($t5)         	        # Carrega o conteúdo (0-8, ou 9 para mina) em $a0
    	
        addi $a0, $a0, 48       	# Convertemos o número para caractere, pois 48 é o ASCII de 0
    
        li $v0, 11
        syscall

  fimDaCelula:
	
        li $v0, 4			# imprime o " | "
        la $a0, barra
        syscall
    
        addi $t2, $t2, 1
        j loopColunas	
    
  proxLinha:
        li $v0, 4
        la $a0, novaLinha        	# Faz a quebra de linha
        syscall
        addi $t1, $t1, 1
        
        j loopLinhas			# Volta para as colunas da prox linha
  
  fimShow:
        jr $ra
    
getEntrada:				      
        li $v0, 4        	                # Printar String
        la $a0, entrada
        syscall
    						# Le o primeiro inteiro (linha)
        li $v0, 5          	        
        syscall              	        
					
        move $t0, $v0        	     	        # Salva a linha em $t0

        li $v0, 5               		# Le o segundo inteiro (coluna)  
        syscall                  
   					
        move $t1, $v0                           # Salva a coluna em $t1
 
        blt $t0, 0, entradaInvalida		# Verifica se a linha é menor que 0
   					 
        bgt $t0, 9, entradaInvalida		# Verifica se a linha é maior que 9

        blt $t1, 0, entradaInvalida   	        # Verifica se a coluna é menor que 0
  
        bgt $t1, 9, entradaInvalida        	# Verifica se a coluna é maior que 9

        move $v0, $t0           	        # Move a linha válida para $v0
        move $v1, $t1              	        # Move a coluna válida para $v1
        jr $ra                 	   	   	# Retorna a função

  entradaInvalida:

        li $v0, 4           	   	  	# Printar mensagem de erro
        la   $a0, erroInvalido
        syscall
    
        j getEntrada				# Volta para o começo para pedir a entrada novamente
	
jogaMinas:
	la $t0, tabuleiroLogico			# Endereço base do tabuleiro logico
	li $t1, 0				# Contador de minas posicionadas
	li $t2, 20				# número de minas que serão posicionadas
	
  loopJogaMinas:
        bge $t1, $t2, fimJogaMinas		# Condição de parada quando posicionar todas as minas
	
        li $a0, 0            			# ID do gerador de aleatórios (pode ser qualquer um)
        li $a1, 10          	       	        # Limite superior, de 0 a 9
        li $v0, 42                 	 	# Syscall 42 para gerar um inteiro aleatório
        syscall
        move $t3, $a0            	  	# $t3 guarda a linha aleatória

        li $a0, 0				
        li $a1, 10			
        li $v0, 42				# Syscall 42 para gerar um int aleatório
        syscall
        move $t4, $a0            		# $t4 guarda a coluna aleatória

        li $t5, 10
        mult $t3, $t5            	        # linha * 10
        mflo $t5
        add $t5, $t5, $t4       		# $t5 = índice (linha * 10 + coluna)
        add $t6, $t0, $t5         		# $t6 = endereço da célula

        lb $t7, 0($t6)           		# Carrega o valor q está na célula
        bne $t7, 0, loopJogaMinas  		# Se n for 0 (tem mina), ignora essa tentativa
            
        li $t7, 9                 		# Carrega o valor da mina (9)
        sb $t7, 0($t6)            		# Salva a mina no tabuleiro lógico

        addi $t1, $t1, 1
        j loopJogaMinas

  fimJogaMinas:
        jr $ra
    
contaMinas:
	addi $sp, $sp, -4		# Abre espaço na pilha para 4 bytes (1 palavra)
	sw $ra, 0($sp)			# Salva o valor de $ra para a pilha
	
	la $s0, tabuleiroLogico		# Endereço base do tabuleiro lógico
	li $s1, 0			# Contador de linha atual

 loopLinhasContaMinas:
	bge $s1, 10, fimContaMinas

	li $s2, 0			# Contador de coluna atual
	
  loopColunasContaMinas:
	bge $s2, 10, proximaLinhaContaMinas

	li $t0, 10			# Calcula o indice e endereço da celula atual
	mult $s1, $t0		
	mflo $t0
	add $t0, $t0, $s2		# $t0 = índice da célula atual
	add $t1, $s0, $t0		# $t1 = endereço da célula atual

	lb $t2, 0($t1)			# Verifica se a célula atual é uma mina e, se for, pula para a prox
	li $t3, 9
	beq $t2, $t3, proximaCelulaContaMinas

	li $t4, 0			# $t4 = contador de minas vizinhas

	addi $t5, $s1, -1		# Vizinho 1: (linha-1, coluna-1)
	addi $t6, $s2, -1
	jal checaVizinho		# Chama uma sub-rotina para não repetir código
	
	addi $t5, $s1, -1		# Vizinho 2: (linha-1, coluna)
	move $t6, $s2
	jal checaVizinho

	addi $t5, $s1, -1		# Vizinho 3: (linha-1, coluna+1)
	addi $t6, $s2, 1
	jal checaVizinho

	move $t5, $s1			# Vizinho 4: (linha, coluna-1)
	addi $t6, $s2, -1
	jal checaVizinho


	move $t5, $s1			# Vizinho 5: (linha, coluna+1)
	addi $t6, $s2, 1
	jal checaVizinho

	addi $t5, $s1, 1		# Vizinho 6: (linha+1, coluna-1)
	addi $t6, $s2, -1
	jal checaVizinho

	addi $t5, $s1, 1		# Vizinho 7: (linha+1, coluna)
	move $t6, $s2
	jal checaVizinho

	addi $t5, $s1, 1		# Vizinho 8: (linha+1, coluna+1)
	addi $t6, $s2, 1
	jal checaVizinho

	sb $t4, 0($t1)			# Salva o número total de minas em $t4

  proximaCelulaContaMinas:
	addi $s2, $s2, 1		# j = j + 1
	j loopColunasContaMinas

  proximaLinhaContaMinas:
	addi $s1, $s1, 1		# i = i + 1
	j loopLinhasContaMinas

  fimContaMinas:
	lw $ra, 0($sp)			# Restaura o valor original de $ra da pilha	
	addi $sp, $sp, 4		# Libera a pilha
	jr $ra
	
  checaVizinho:
	blt $t5, 0, fimChecaVizinho	# Verifica Limites da linha (0 <= vx < 10)
	bge $t5, 10, fimChecaVizinho

	blt $t6, 0, fimChecaVizinho	# Verifica Limites da coluna (0 <= vy < 10)
	bge $t6, 10, fimChecaVizinho


	li $t7, 10			# Se chegou até aqui, calcula o índice e endereço do vizinho
	mult $t5, $t7
	mflo $t7
	add $t7, $t7, $t6		# $t7 = índice do vizinho
	add $t8, $s0, $t7		# $t8 = endereço do vizinho
	
	lb $t9, 0($t8)			# Verifica se o vizinho é uma mina
	li $t7, 9
	bne $t9, $t7, fimChecaVizinho	# Se não for 9, não faz nada


	addi $t4, $t4, 1		# Se for uma mina, incrementa o contador

  fimChecaVizinho:
	jr  $ra 			# Retorna para a função principal	

revelaCelula:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    move $t0, $v0
    move $t1, $v1

    la   $s0, tabuleiroLogico
    la   $s1, tabuleiroVisivel

    li   $t2, 10
    mult $t0, $t2
    mflo $t2
    add  $t2, $t2, $t1      # t2 = índice

   
    add  $t3, $s1, $t2
    lb   $t6, 0($t3)
    bne  $t6, 0, jaRevelada

    # olha o lógico
    add  $t3, $s0, $t2
    lb   $t4, 0($t3)
    li   $t5, 9
    beq  $t4, $t5, acertouMina

    bne  $t4, $zero, celulaComNumero

    # se == 0, chama inundacao
    move $a0, $t0
    move $a1, $t1
    jal  inundacao
    j    fimRevela

celulaComNumero:
    # para valores diferente de 0, revela e retorna
    add  $t3, $s1, $t2
    li   $t4, 1
    sb   $t4, 0($t3)
    li   $v0, 0
    j    fimRevela

acertouMina:
    add  $t3, $s1, $t2
    li   $t4, 1
    sb   $t4, 0($t3)
    li   $v0, 0
    li   $v0, -1
    j    fimRevela

jaRevelada:
    li   $v0, 0

fimRevela:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

inundacao:
	
	addi $sp, $sp, -20		# Salvar os endereços pois serão modificados
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $a0, 12($sp)			# Salva a linha atual
	sw $a1, 16($sp)			# Salva a coluna atual

	blt $a0, 0, fimInundacao	# Se a coordenada estiver fora do tabuleiro, retorna.
	bge $a0, 10, fimInundacao
	blt $a1, 0, fimInundacao
	bge $a1, 10, fimInundacao
	
	la $s0, tabuleiroLogico
	la $s1, tabuleiroVisivel

	li $t2, 10		
	mult $a0, $t2
	mflo $t2
	add $t2, $t2, $a1		# $t2 = indice

	add $t3, $s1, $t2		# Se a célula já foi revelada, retorna.
	lb $t4, 0($t3)
	bne $t4, 0, fimInundacao

	li $t4, 1			# Revela a célula atual no tabuleiro visível
	sb $t4, 0($t3)

	add $t3, $s0, $t2		# Verifica o conteúdo no tabuleiro lógico
	lb $t4, 0($t3)

	bne $t4, 0, fimInundacao	# Se o conteúdo for diferente de 0, paramos a inundação
	
	lw $a0, 12($sp)       	# Vizinho 1 (Topo-Esquerda: l-1, c-1) 
	lw $a1, 16($sp)        
	addi $a0, $a0, -1        
	addi $a1, $a1, -1        
	jal inundacao

	lw $a0, 12($sp)		# Vizinho 2 (Topo-Meio: l-1, c)
	lw $a1, 16($sp)
	addi $a0, $a0, -1        
	jal inundacao

	lw $a0, 12($sp)		# Vizinho 3 (Topo-Direita: l-1, c+1)
	lw $a1, 16($sp)
	addi $a0, $a0, -1       
	addi $a1, $a1, 1       
	jal inundacao

	lw $a0, 12($sp)		# Vizinho 4 (Meio-Esquerda: l, c-1)
	lw $a1, 16($sp)
	addi $a1, $a1, -1        
	jal inundacao

	lw $a0, 12($sp)		# Vizinho 5 (Meio-Direita: l, c+1)
	lw $a1, 16($sp)	
	addi $a1, $a1, 1       
	jal inundacao

	lw $a0, 12($sp)		# Vizinho 6 (Baixo-Esquerda: l+1, c-1)
	lw $a1, 16($sp)
	addi $a0, $a0, 1        
	addi $a1, $a1, -1       
	jal inundacao

	lw $a0, 12($sp)		# Vizinho 7 (Baixo-Meio: l+1, c)
	lw $a1, 16($sp)
	addi $a0, $a0, 1        
	jal inundacao

	lw $a0, 12($sp)		# Vizinho 8 (Baixo-Direita: l+1, c+1)
	lw $a1, 16($sp)
	addi $a0, $a0, 1        
	addi $a1, $a1, 1         
	jal inundacao

  fimInundacao:
	lw $ra, 0($sp)		# Restaura a pilha na ordem inversa
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $a0, 12($sp)
	lw $a1, 16($sp)
	addi $sp, $sp, 20
	jr $ra

verificaFim:
	la $s0, tabuleiroVisivel
	li $t0, 0              # índice i
	li $t1, 0              # contador de células reveladas

  loopVerifica:
	bge $t0, 100, fimLoopVerifica

	add $t2, $s0, $t0
	lb $t3, 0($t2)
	
	bne $t3, 1, proximaVerifica
	addi $t1, $t1, 1

  proximaVerifica:
	addi $t0, $t0, 1
	j loopVerifica

  fimLoopVerifica:
	li $t2, 80
	bne $t1, $t2, naoVenceu

	li $v0, 1              # Retorna 1 para vitória
	jr $ra

  naoVenceu:
	li $v0, 0              # Retorna 0 para continuar o jogo
	jr $ra

controlaJogo:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

  loopPrincipal:
	jal showTabuleiro
	jal getEntrada
	jal revelaCelula
	
	blt $v0, 0, acertouMinaControla

	# Verifica se o jogador venceu após a jogada
	jal verificaFim
	beq $v0, 1, vitoriaControla

	# Se nada aconteceu, continua o loop
	j loopPrincipal

  acertouMinaControla:
	li $a0, 0              # Argumento 0 = derrota
	jal encerraJogo
 
  vitoriaControla:
	li $a0, 1              # Argumento 1 = vitória
	jal encerraJogo

  fimControlaJogo:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

encerraJogo:
	jal showTabuleiro       # Mostra o tabuleiro uma última vez

	bne $a0, 1, msgDeDerrota

	li $v0, 4
	la $a0, msgVitoria	# Jogador venceu
	syscall
	j fimDoPrograma

  msgDeDerrota:
	li $v0, 4
	la $a0, msgDerrota	# Jogador perdeu
	syscall

  fimDoPrograma:
	li $v0, 10             # Termina a execução
	syscall
