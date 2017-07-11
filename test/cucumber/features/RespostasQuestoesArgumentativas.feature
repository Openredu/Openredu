Feature: Respostas das Questões Argumentativas
    As a usuário esteja logado no sistema
    I want listar e adicionar respostas e  listar questões
    So that possa responder e analisar as questões dissertativas

	Scenario: listar questoes respondidas 
		Given o sistema tem a questão "Faça um cenário" respondida
		And eu estou logado como “aluno” 
		When eu vejo a lista de questões respondidas
		Then a lista de questões respondidas contém a questão "Faça um cenário"

	Scenario: listar questões respondidas web
		Given que o “aluno” esteja logado
		And o sistema contenha a questão respondida “Como criar seu GitHub”
		And esteja no menu de questões dissertativas 
		When selecionar a aba de questões respondidas
		Then a lista irá conter “Como criar seu GitHub”


