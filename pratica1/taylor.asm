.data 
    pega_x: .asciiz "Digite o valor de x: "
    resposta_cos: .asciiz "Valor de cos(x): "
    resposta_sen: .asciiz "\nValor de sen(x): "
    
    pi: .float 3.1415926535 #valor de pi 
    grau_180:.float 180.0 # valor de 180 graus 
    negativo_t:.float -1.0 
    um_float: .float 1.0 
    precisao: .float 0.00001
    
.text
.globl main

main:
    li $v0, 4
    la $a0, pega_x #valor de x 
    syscall
    
    li $v0, 6 # le o valor 
    syscall
    
    mov.s $f24, $f0
    
    mov.s $f12, $f24
    jal cos_func
    
    mov.s $f12, $f0 #move o resultado para f0
    
    li $v0, 4
    la $a0, resposta_cos
    syscall

    li $v0, 2 #imprime resultado
    syscall
    
    mov.s $f12, $f24 #restaura o valor de x
    jal sen_func
    
    mov.s $f12, $f0 #move o resultado para f0
    
    li $v0, 4    
    la $a0, resposta_sen
    syscall

    li $v0, 2 #imprime resultado
    syscall

    #fim do programa
    li $v0, 10
    syscall
    
sen_func:
    # rad = graus * pi / 180
    l.s $f14, pi    
    l.s $f16, grau_180   
    mul.s $f12, $f12, $f14 #x = x * pi
    div.s $f12, $f12, $f16 # x = (x * pi) / 180

    mov.s $f2, $f12 # soma = x
    mov.s $f4, $f12 # termo = x

    # recorrencia
    mul.s $f18, $f12, $f12 # $f18 = x*x 

    # primeiro denominador a ser usado eh 2*3. n inicia como 2
    l.s   $f8, um_float
    add.s $f6, $f8, $f8 # n = 2.0

sen_loop:

    # t_novo = t_velho * (-1) * (x*x) / (n * (n+1))
    l.s   $f20, negativo_t
    mul.s $f4, $f4, $f18 # t = t * (x*x)
    mul.s $f4, $f4, $f20 # t = t * (-1) ; inverte o sinas

    div.s $f4, $f4, $f6 # t = t / n
    add.s $f6, $f6, $f8 # n = n + 1
    div.s $f4, $f4, $f6 # t = t/ (n+1)

    add.s $f2, $f2, $f4 

    add.s $f6, $f6, $f8
    
    l.s   $f10, precisao

    abs.s $f22, $f4

    c.lt.s $f22, $f10 #compara termo e precisao
    bc1t fim_sen_loop 
    j sen_loop

fim_sen_loop:
    mov.s $f0, $f2
    jr $ra

    
cos_func:
    # rad = graus * pi / 180
    l.s $f14, pi    
    l.s $f16, grau_180   
    mul.s $f12, $f12, $f14 # x = x * pi
    div.s $f12, $f12, $f16 # x = (x * pi) / 180
    
    l.s $f2, um_float # soma = 1.0
    l.s $f4, um_float # termo = 1.0

    # recorrencia ao usar x*x
    mul.s $f18, $f12, $f12 # $f18 = x*x 

    # n inicia como 1 para cos
    l.s $f6, um_float # n = 1
cos_loop:

    # t_novo = t_velho * (-1) * (x*x) / (n * (n+1))
    l.s   $f20, negativo_t
    mul.s $f4, $f4, $f18 # t = t * (x*x)
    mul.s $f4, $f4, $f20 # t = t * (-1) ; inverte o sina

    div.s $f4, $f4, $f6 # t = t / n
    add.s $f6, $f6, $f8 # n = n + 1
    div.s $f4, $f4, $f6 # t = t/ (n+1)

    add.s $f2, $f2, $f4 

    add.s $f6, $f6, $f8
    
    l.s   $f10, precisao
    abs.s $f22, $f4
    c.lt.s $f22, $f10
    bc1t fim_cos_loop
    j cos_loop
    

fim_cos_loop:
    mov.s $f0, $f2        
    jr $ra
    
