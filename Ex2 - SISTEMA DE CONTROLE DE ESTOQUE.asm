## GRUPO
# Nome: Luís Fernando De Mesquita Pereira  RA: 10410686
# Nome: Marcelo Luis Simone Lucas RA: 10332213
# Nome: Rayane Yumi Da Silva Tahara RA: 10410892

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
	
	msgItemNaoEncontrado: .asciiz "\nItem não encontrado..."
	msgCodigoJaCadastrado: .asciiz "\nCódigo já está cadastrado!"
.text 

## REGISTRADORES - USO
# $t0 - Guarda a opção escolhida pelo usuário
# $s1 - Head
# $t3 - Armazena endereço do NEXT nó anterior
j main

inserirItem:
	li $s0, 0 # Carrega 0 em $s0 (NULL)
	bnez $s1, elseInicializarPonteiroHead
	# Inicializa o ponteiro Head para o primeiro nó da lista encadeada
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
    	
    	la $t3, ($s1) # Carrega ponteiro head para $t3
    	beqz $t3, elseInserirNo # Verifica se head já foi iniciado
    	# Se a lista já contém algum item
    	
    	loopVerificaCodigoCadastrado:
    		lw $t6, 0($t3) # Carrega o código do nó  
    		lw $t3, 8($t3) # Carrega o contéudo do ponteiro NEXT do nó 
    		beq $t2, $t6, elseCodigoJaCadastrado # Verifica se o código já está cadastrado na lista 
    		beqz $t3, elseInserirNo # Se chegou no último nó significa que nenhum item tem o mesmo código,
    			# Então segue para o label elseInserirNo
    		j loopVerificaCodigoCadastrado # Continua no laço se next for diferente de NULL (0)
    		
    	elseInserirNo:
    	# Armazenar valores no nó
    	sw $t1, 0($s2) # Armazena o código do produto no endereço do nó, do byte 0 até o byte 4
    	sw $t2, 4($s2) # Armazena a quantidade do produto no endereço do nó, do byte 4 até o byte 8
    	sw $s0, 8($s2) # Ponteiro do nó iniciado como nulo (0)
    	
    	bnez $s1, elseApontarHead # Condição para verificar se é o primeiro nó que está sendo criado
    	la $t3, 8($s2)  # Armazenar o valor do next do nó anterior 
    	move $s1, $s2 #Apontar Head para o primeiro nó da lista
	j voltar
	
    	elseApontarHead:
    	
    	la $t3, ($s1) # Carrega ponteiro head para $t3
    	loopInserirItem:
    		la $t4, 8($t3) # Carrega o endereço do ponteiro NEXT do nó 
    		lw $t3, 8($t3) # Carrega o contéudo do ponteiro NEXT do nó 
    		bnez $t3, loopInserirItem # Verifica se NEXT é nulo
    			# Se não for continua no loop, se for então o último nó foi encontrado
    		
    	sw $s2, ($t4) # Ponteiro next do nó anterior, apontando para o endereço do próximo nó
    		
    	voltar:    	    	
	jr $ra # Volta para main
	
elseCodigoJaCadastrado: #TODO
    		li $v0, 4
    		la $a0, msgCodigoJaCadastrado
    		syscall
    		j voltar
    		
excluirItem:
	beqz $s1, nenhumItemCadastrado # Verifica se head é nulo ($s1 = 0), 
	# caso sim vai para o label nenhumItemCadastrado

	li $v0, 4 # Solicita o código do produto ao usuário
	la $a0, textoCodigoProduto # Carrega o texto da variável textoCodigoProduto para $a0 
	syscall # Chama sistema para printar a string
	
	li $v0, 5 # Lê o código do produto do usuário                
	syscall
	
	move $t0, $v0 # Move o código do produto informado pelo usuário em $t0
	move $t1, $s1  # Copia o valor de $s1 (head) para $t1
	li $t2, 0 # Iniciliza um contador de apoio em 0
		
	buscarItemLoop:
	addi $t2, $t2, 1 # Incremento de $t2 em 1
	lw $t3, 0($t1) # Carrega o código do produto do nó para $t3
	
	beq $t3, $t0, exluirItemEncontrado  # Se igual o item foi encontrado na lista, 
	# então vai para o label exluirItemEncontrado
	la $t4, 8($t1) # Armazena o valor do ponteiro NEXT do nó anterior 
	
	lw $t1, 8($t1) # Atualiza o ponteiro para o endereço do próximo nó (NEXT)
	beqz $t1, itemNaoEncontrado # Verifica se existe outro nó, ou seja, se o ponteiro next não é nulo
	# senão vai para o label itemNaoEncontrado
	
	j buscarItemLoop # Volta para o laço

	exluirItemEncontrado:
	lw $t6, 8($t1) # Carrega para $t6 o endereço do próximo nó (NEXT)
	
	beq $t2, 1, elsePrimeiroNo # Verifica se é primeiro nó, usando o contador de apoio $t2, caso seja vai para o label elsePrimeiroNo
	
	# Caso não seja o primeiro, nem o último nó
	lw $t5, 8($t1) # Carrega o ponteiro next do nó atual para $t5
	sw $t5, ($t4) # Atualiza o ponteiro next do nó anterior com o next do nó atual
	
	j voltarMain # Vai para label voltarMain
	elsePrimeiroNo: 
	
	beqz $t6, elsePrimeiroNoNextNulo # Verifica next primeiro nó é nulo, caso sim vai para label elsePrimeiroNoNextNulo
	
	# Caso o 1° nó tiver ponteiro NEXT diferente de nulo, então o head será atualizado
	# para o next do 1º nó
	lw $t5, 8($t1) # Carrega ponteiro next do primeiro nó para $t5
	move $s1, $t5 # Atualiza head com ponteiro next do primeiro né
	
	j voltarMain   # Vai para label voltarMain

	elsePrimeiroNoNextNulo:
	move $s1, $zero # Atualiza o head para nulo, pois o primeiro nó foi excluido
		      # E como não existem outros nós, o head volta para 0 (NULL)

	j voltarMain # Vai para label voltarMain
	
	nenhumItemCadastrado:
		li $v0, 4 # Imprime mensagem informando que nenhum item foi cadastrado ainda
		la $a0, msgNenhumItemCadastrado # Carrega o endereço da variável msgNenhumItemCadastrado para $a0
		syscall # Chama sistema 
		j voltarMain # Vai para label voltarMain
		
	itemNaoEncontrado:
		li $v0, 4 # Imprime mensagem de item não encontrado
		la $a0, msgItemNaoEncontrado # Carrega o endereço da variável msgItemNaoEncontrado para $a0
		syscall # Chama sistema
		j voltarMain # Vai para label voltarMain

	voltarMain:
		jr $ra # Volta para main

buscarItemPorCodigo:
	# Solicita o código do produto ao usuário
	li $v0, 4               
	la $a0, textoCodigoProduto
	syscall

	# Lê o código do produto do usuário
	li $v0, 5                
	syscall
	move $t6, $v0            # Armazena o código que o usuário quer buscar em $t6

	# Inicializa o ponteiro em $t4, onde $s1 é o endereço de memoria inicial[head]
	move $t4, $s1           

buscarlLoop:
	# Verifica se o ponteiro em armazenado em $t4 é nulo, caso sim itemNãoEncontrado
	beqz $t4, ItemNãoEncontrado

    
	lw $t7, 0($t4)           # Carrega o código do produto da lista em $t7
	beq $t6, $t7, itemEncontrado  #Caso o Código for igual, ItemEncontrado

    	# Move para o próximo nó
	lw $t4, 8($t4)           # Atualiza $t4 com o endereço do próximo nó ou null
	j buscarlLoop            # Repeti o Loop

itemEncontrado:
	# Imprime o código do produto encontrado
	li $v0, 4               
	la $a0, textoExibeCodigoProduto
	syscall
	#imprimi o Código do produto encontrado
	li $v0, 1                
	move $a0, $t6
	syscall

	# Imprime a quantidade do produto encontrado
	li $v0, 4                
	la $a0, textoExibeQuantidadeProduto
	syscall
	#Carrega a quantidade que está alocada no proximo endereço(+4) em $a0
	lw $a0, 4($t4)           
	li $v0, 1                # Realiza o print
	syscall
	j fimBuscar             # Finaliza a busca

ItemNãoEncontrado:
	# Imprime mensagem de item não encontrado
	li $v0, 4
	la $a0, msgNenhumItemCadastrado
	syscall

fimBuscar:
	jr $ra                   # Retorna para a função principal
	
	
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
