.data 

#Inicializar Dados para QtSpim

inicio:		
	#Mensagens

	mensagem1:		.asciiz "Digite a taxa de aprendizado no neuronio: "
	mensagem2:		.asciiz "Digite o numero de epocas que deseja treinar: "
	mensagem3:		.asciiz "Digite o numero de dados para treinamento: "
	mensagem4:		.asciiz "Pesos iniciais: "
	mensagem5:		.asciiz "Novos Pesos: "
	mensagem6:		.asciiz "\nEtapa de Testes\n"
	
	#Sinais

        espaco:		.asciiz " "
	mais:		.asciiz "+"
	igual:		.asciiz "= "
	Dados: 	        .asciiz "\nDado:"
	barraN:		.asciiz "\n"
	


	pesoUm: 		.float 0.0
	pesoDois:		.float 0.0  
	taxaAprendizado: 	.float 0.0 
	QtdEpocas: 		.word 0 
	QtdDados: 		.word 0 
	DadosEntrada:		.word 0 		
														
.text 

main:			
	#Pedir para o usuário a taxa de aprendizado
	addi $v0, $zero, 4
	la $a0, mensagem1
	syscall

        #Ler e armazenar 
	addi $v0, $zero, 6
	syscall
	swc1 $f0, taxaAprendizado
			
	#Pedir para o usuário a quantidade de epocas
	addi $v0, $zero, 4
	la $a0, mensagem2
	syscall

	#Ler e armazenar 
	addi $v0, $zero, 5
	syscall
	sw $v0, QtdEpocas
			
	#Pedir para o usuário a quantidade de dados para treinar
	addi $v0, $zero, 4
	la $a0, mensagem3
	syscall

	#Ler e armazenar
	addi $v0, $zero, 5
	syscall
	sw $v0, QtdDados
			
			
	#Inicializa o FOR0
	lw $s0, QtdDados
	add $t0, $zero, $zero
	addi $t4, $zero, 4
		
	#Esse for é para preencher o vetor de dados de entrada 
        FOR0:   slt $t1, $t0, $s0
                beq $t1, $zero, FIMFOR0
                mul $t2, $t0, $t4
                        	
		#Solicita o dado atual do vetor de dados
		addi $v0, $zero, 4
		la $a0, Dados
		syscall
				
		# le e armazena o dado no vetor
		addi $v0, $zero, 5
		syscall
		sw $v0, DadosEntrada($t2)	
				
		#i++
		addi $t0, $t0, 1
                j FOR0	
       FIMFOR0:
       
       	#Gerar um numero aleatorio para os pesos
	addi $v0, $zero, 43 
	syscall
	swc1 $f0, pesoUm #Armazenar o numero aleatorio para peso 1 
	syscall
	swc1 $f0, pesoDois #Armazenar o numero aleatorio para peso 2
       
        # Mostra pesos inicias do neuronio
	addi $v0, $zero, 4
	la $a0, mensagem4
	syscall
       
        lwc1 $f12, pesoUm 
	addi $v0, $zero, 2
	syscall
	
	addi $v0, $zero, 4
	la $a0, espaco
	syscall
	
	lwc1 $f12, pesoDois
	addi $v0, $zero, 2 
	syscall
       
        # Carrega a taxa de aprendizado em $f3
        lwc1 $f3, taxaAprendizado

        # Inicializa o FOR1
	lw $s0, QtdEpocas
	add $t0, $zero, $zero
		
	#Esse for é para executar todas as épocas
        FOR1:  	slt $t1, $t0, $s0
                beq $t1, $zero, FIMFOR1
		
		
		# Inicializa o FOR2
		lw $s1, QtdDados
		add $t5, $zero, $zero
		# For para treinar todos os dados
        	FOR2:
        		# Condição de parada do FOR0
        		slt $t6, $t5, $s1
                	beq $t6, $zero, FIMFOR2
                	# Controle da posição atual do vetor
                	mul $t2, $t5, $t4
                	
               
      			lw $s2,DadosEntrada($t2)
      			mtc1 $s2, $f13
  			cvt.s.w $f13, $f13
      			lwc1 $f4, pesoUm
      			lwc1 $f5, pesoDois
      			
      			#funcao de ativacao
    			#equação res= pesoA*dados[j] + pesoB*dados[j] => dados[j] * (pesoA + pesoB)
      			add.s $f0, $f4, $f5
      			mul.s $f1, $f13, $f0
      			
      			# erro = (2*dados[j]) - res
      			add.s $f0, $f13, $f13
      			sub.s $f2, $f0, $f1
      			
      			
      			#calculo dos novos pesos
      			mul.s $f0, $f2, $f3
      			mul.s $f0, $f0, $f13
      			#pesoA += erro * taxa * dados[j]
      			add.s $f4, $f4, $f0
      			swc1 $f4, pesoUm
      			#pesoB += erro * taxa * dados[j]
      			add.s $f5, $f5, $f0
      			swc1 $f5, pesoDois
      			
      			#printf("\n%d + %d = %.2f", dados[j], dados[j], res);
      			# Print do resultado
      			addi $v0, $zero, 4
			la $a0, barraN
			syscall
      			add $a0, $s2 ,$zero 
			addi $v0, $zero, 1
			syscall
			
      			addi $v0, $zero, 4
			la $a0, mais
			syscall
			
			add $a0, $s2 ,$zero 
			addi $v0, $zero, 1
			syscall
			
			addi $v0, $zero, 4
			la $a0, igual
			syscall
			
			sub.s $f11, $f11, $f11
			add.s $f12, $f1, $f11
			addi $v0, $zero, 2 
			syscall
			
      			#printf("\nNovos pesos - A: %.2f, B: %.2f\n", pesoA, pesoB);
      			# Mostra pesos novos do neuronio
			addi $v0, $zero, 4
			la $a0, mensagem5
			syscall
       
        		add.s $f12, $f4, $f11
			addi $v0, $zero, 2
			syscall
	
			addi $v0, $zero, 4
			la $a0, espaco
			syscall
	
			add.s $f12, $f5, $f11
			addi $v0, $zero, 2 
			syscall
				
				
				
			#i++
			addi $t5, $t5, 1
                	j FOR2	
       		FIMFOR2:
		
				
		#i++
		addi $t0, $t0, 1
                j FOR1	
       FIMFOR1:
       
        addi $v0, $zero, 4
	la $a0, mensagem6
	syscall
                 
        #Pesos
        lwc1 $f4, pesoUm
        lwc1 $f5, pesoDois       
        #inicializa FOR3                
 	lw $s0, QtdDados
     	add $t0, $zero, $zero

	# For para executar fase de testes
        FOR3:
        	# Condição de parada do FOR3
                slt $t1, $t0, $s0
       		beq $t1, $zero, FIMFOR3
                
             	# Solicita o dado atual do vetor de dados
		addi $v0, $zero, 4
		la $a0, Dados
		syscall
				
		# le e armazena o dado no vetor
		addi $v0, $zero, 5
		syscall
  		add $s2, $v0, $zero
		mtc1 $s2, $f13
  		cvt.s.w $f13, $f13
		
		#//funcao de ativacao
      		#equação res= pesoA*dados[j] + pesoB*dados[j] => dados[j] * (pesoA + pesoB)
      		add.s $f0, $f4, $f5
      		mul.s $f1, $f13, $f0
      		
   		#printf("\n%d + %d = %.2f", dados[j], dados[j], res);
      		# Print do resultado
      		addi $v0, $zero, 4
		la $a0, barraN
		syscall
      		add $a0, $s2 ,$zero 
		addi $v0, $zero, 1
		syscall
			
      		addi $v0, $zero, 4
		la $a0, mais
		syscall
			
		add $a0, $s2 ,$zero 
		addi $v0, $zero, 1
		syscall
			
		addi $v0, $zero, 4
		la $a0, igual
		syscall
			
		sub.s $f11, $f11, $f11
		add.s $f12, $f1, $f11
		addi $v0, $zero, 2 
		syscall
             	
             	# i++
                addi $t0, $t0, 1
        	j FOR3
	FIMFOR3:        
                        
                        
          
                        
                        
	jr $ra #Fim do programa
