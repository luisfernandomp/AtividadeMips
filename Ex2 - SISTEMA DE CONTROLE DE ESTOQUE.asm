.data
	textoTitulo: .asciiz "\n\n**** SISTEMA DE CONTROLE DE ESTOQUE ****\n"
	textoMenu: .asciiz "\n1. Inserir um novo item no estoque\n2. Excluir um item do estoque\n3. Buscar um item pelo código\n4. Atualizar quantidade em estoque\n5. Imprimir os produtos em estoque\n6. Sair\nOpção: "
	textoSair: .asciiz "\nSaindo..."
	textoOpcaoInvalida: .asciiz "\nOpção Inválida!"
	
	textoCodigoProduto: .asciiz "\nDigite o código do produto: "
	textoQuantidadeProduto: .asciiz "Digite a quantidade do produto: "

	textoImprimirEstoque: .asciiz "\nLISTAGEM PRODUTOS ESTOQUE"
	delimitador: .asciiz "\n--------------------------------"	
	textoExibeCodigoProduto: .asciiz "\nCódigo: \t"
	textoExibeQuantidadeProduto: .asciiz "\nQuantidade em Estoque: \t"
	textoTotalItens: .asciiz "\nTotal itens: \t"
	msgNenhumItemCadastrado: .asciiz "\nNenhum item cadastrado..."
	
.text 

## REGISTRADORES - USO
# $t0 - Guarda a opção escolhida pelo usuário
# $s1 - Head
# $t3 - Armazena endereço do NEXT nó anterior

j main

inserirItem:
	bnez $s1, elseInicializarPonteiroHead
	# Inicializa o ponteiro Head para o primeiro nó da lista encadeada
	li $s0, 0 # Carrega 0 em $s0 (NULL)
	la $s1, ($s0) # Carrega o endereço do 1º nó em $s1 (head)

	elseInicializarPonteiroHead:	
	# Aloca espaço no heap para o primeiro nó da lista
	li $a0, 12      # 12 bytes para armazenar um ponteiro e dois valores inteiros (código e quantidade do produto)
    	li $v0, 9       # Syscall para alocar memória no heap
    	syscall
    	move $s2, $v0  # Armazena o endereço do nó alocado na heap em $s2
    	
    	# Pede para o usuário entrar com o valor do código do produto
    	li $v0, 4 # Syscall para printar uma string
    	la $a0, textoCodigoProduto
    	syscall
    	
    	# Lê a entrada do usuário para o código do produto
    	li $v0, 5 # Syscall para ler um inteiro
    	syscall
    	move $t1, $v0
    	
    	# Pede para o usuário entrar com a quantidade do produto
    	li $v0, 4 # Syscall para printar uma string
    	la $a0, textoQuantidadeProduto
    	syscall
    	
    	# Lê a entrada do usuário para o código do produto
    	li $v0, 5 # Syscall para ler um inteiro
    	syscall
    	move $t2, $v0
    	
    	# Armazenar valores no nó
    	sw $t1, 0($s2) # Armazena o código do produto no endereço do nó, do byte 0 até o byte 4
    	sw $t2, 4($s2) # Armazena a quantidade do produto no endereço do nó, do byte 4 até o byte 8
    	sw $s0, 8($s2) # Ponteiro do nó iniciado como nulo (0)
    	
    	bnez $s1, elseApontarHead # Condição para verificar se é o primeiro nó que está sendo criado
    	la $t3, 8($s2)  # Armazenar o valor do next do nó anterior 
    	move $s1, $s2 #Apontar Head para o primeiro nó da lista
	j voltar
	
    	elseApontarHead:
    	sw $s2, 0($t3) # Ponteiro next do nó anterior, apontando para o endereço do próximo nó
    	la $t3, 8($s2) # Atualiza $t3 com o valor do next do nó anterior
    	
    	voltar:    	    	
	jr $ra # Volta para main

excluirItem:
	#TODO
	jr $ra # Volta para main

buscarItemPorCodigo:
	#TODO
	jr $ra # Volta para main	
	
atualizarQuantidadeItem:
	#TODO
	jr $ra # Volta para main			

imprimirItens:

	bnez $s1, elseVerificarListaVazia # Verifica se a lista não está vazia
	li $v0, 4 
	la $a0, msgNenhumItemCadastrado # Informa ao usuário que a lista não tem nenhum item 
	syscall
	j fim # Sai do laço

	elseVerificarListaVazia: # Inicia a impressão caso haja pelo menos um item na lista
	li $v0, 4 
	la $a0, delimitador # Imprimindo delimitador 
	syscall
	
	li $v0, 4 
	la $a0, textoImprimirEstoque # Imprimindo delimitador 
	syscall

	li $t5, 0 # Variável de controle, para exibir o total de itens na listagem
	la $t4, ($s1) # Ponteiro auxiliar para percorrer a lista, $t5 = HEAD
	
	loop_imprimirItens:
		beqz $t4, fim # Se contador chegou no último nó para o loop
		
		addi $t5, $t5, 1
		li $v0, 4 
		la $a0, delimitador # Imprimindo delimitador 
		syscall
		
		li $v0, 4 
		la $a0, textoExibeCodigoProduto # Imprimindo textoExibeCodigoProduto 
		syscall
		
		li $v0, 1
		lw $a0, 0($t4) # Imprimindo código do produto do nó
		syscall

		li $v0, 4 
		la $a0, textoExibeQuantidadeProduto # Imprimindo textoExibeQuantidadePro 
		syscall
		
		li $v0, 1
		lw $a0, 4($t4) # Imprimindo quantidade do produto do nó
		syscall
						
		lw $t4, 8($t4)
		
		j loop_imprimirItens
	fim: 
	li $v0, 4 
	la $a0, delimitador # Imprimindo delimitador 
	syscall
	
	li $v0, 4 
	la $a0, textoTotalItens # Imprimindo textoTotalItens 
	syscall
	
	li $v0, 1
	la $a0, ($t5) # Imprimindo total de itens
	syscall
	
	li $v0, 4 
	la $a0, delimitador # Imprimindo delimitador 
	syscall
		
	jr $ra # Volta para main

opcaoInvalida:
	li $v0, 4 # Printar string textoOpcaoInvalida para o usuário
	la $a0, textoOpcaoInvalida
	syscall

main:
	loop:
		li $v0, 4 # Printar string textoTitulo para o usuário
		la $a0, textoTitulo
		syscall
	
		li $v0, 4 # Printar string textoMenu para o usuário
		la $a0, textoMenu
		syscall
		
		li $v0, 5 # Ler inteiro com a opção escolhida pelo usuário
		syscall
		move $t0, $v0 # Move a opção escolhida para $t0
	
		bne $t0, 1, case2
		jal inserirItem
		j loop
		case2:
		bne $t0, 2, case3
		jal excluirItem
		j loop
		case3:
		bne $t0, 3, case4
		jal buscarItemPorCodigo
		j loop
		case4:
		bne $t0, 4, case5
		jal atualizarQuantidadeItem
		j loop
		case5:
		bne $t0, 5, case6
		jal imprimirItens
		j loop
		case6:
		beq $t0, 6, sair
		jal opcaoInvalida
		j loop
		
	
sair:
	li $v0, 4 # Printar string textoSair para o usuário
	la $a0, textoSair
	syscall
	
	li $v0, 10 # Syscall para encerrar programa
	syscall
	
					
	
