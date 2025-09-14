.data 
cifra: .space 101
msg_input: .asciiz "Digite a frase que será codificada: (maximo 100 caracteres): "
msg_output: .asciiz "\nMensagem codificada/decodificada: "
msg_size: .asciiz "Digite o tamanho do deslocamento na cifra: "
shift: .word 0 
msg_mode: .asciiz "Digite 'c' para codificar ou 'd' para decodificar: "
mode_var: .space 1





.text
.globl main
main:
 li $v0, 4
 la $a0, msg_input
 syscall


 li $v0, 8
 la $a0, cifra
 la $a1, 101
 syscall


 li $v0, 4 
 la $a0, msg_size
 syscall

 li $v0, 5
 syscall 
 sw $v0, shift
 
li $v0, 4
la $a0, msg_mode
syscall 

li $v0, 12
syscall
sb $v0, mode_var

 li $v0, 4
 la $a0, msg_output
 syscall

 la $t0, cifra
 lw $t2, shift
 li $t3, 26
 la $t7, mode_var
 lb $t8, 0($t7)




loop: 
 lb $t1, 0($t0)
 beqz $t1, fim
 

 li $t4, 97
 li $t5, 122
 
 blt $t1, $t4, verifica_maiuscula
 bgt $t1, $t5, verifica_maiuscula
 
 sub $t6, $t1, $t4
 
 li  $t9, 'c'
 beq $t9, $t8, codifica_minuscula
 
 li $t9, 'd'
 beq $t9, $t8, decodifica_minuscula
 

 


codifica_minuscula: 


 sub $t6, $t1, $t4
 add $t6, $t6, $t2
 add $t6, $t6, $t3
 rem $t6, $t6, $t3
 add $t6, $t6, $t4
 sb $t6, 0($t0)
 j proximo
 

decodifica_minuscula: 
 

 sub $t6, $t1, $t4
 sub $t6, $t6, $t2
 add $t6, $t6, $t3
 rem $t6, $t6, $t3
 add $t6, $t6, $t4
 sb $t6, 0($t0)
 j proximo
 

verifica_maiuscula:

 li $t4, 65
 li $t5, 90

 blt $t1, $t4, proximo
 bgt $t1, $t5, proximo


  
 sub $t6, $t1, $t4
 li $t9,  'c'
 beq $t8, $t9, codifica_maiuscula 
 
 li $t9,  'd'
 beq $t8, $t9, decodifica_maiuscula 
 
 



codifica_maiuscula:

 sub $t6, $t1, $t4
 add $t6, $t6, $t2
 add $t6, $t6, $t3
 rem $t6, $t6, $t3
 add $t6, $t6, $t4
 sb $t6, 0($t0)
 j proximo


decodifica_maiuscula:
   sub $t6, $t1, $t4
   sub $t6, $t6, $t2
   add $t6, $t6, $t3
   rem $t6, $t6, $t3
   add $t6, $t6, $t4 
   sb $t6, 0($t0)
   j proximo

proximo:
 addi $t0, $t0, 1
 j loop

fim:
 li $v0, 4
 la $a0, cifra
 syscall

 li $v0, 10
 syscall 








 
