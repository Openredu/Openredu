@i9n

#Controle

Feature: Respostas das Questões Argumentativas
    As a usuário esteja logado no sistema
    I want listar e adicionar respostas e  listar questões
    So that possa responder e analisar as questões dissertativas
  
Scenario: listar questões respondidas 
    Given que o sistema tenha a questão respondida "Faça um cenário"
    And o usuário esteja logado como aluno
    When ele ver a sua lista de questões 
    Then a lista irá conter "Faça um cenário"

Scenario: listar questões que não foram respondidas  
    Given que o sistema tenha a questões não respondida "Faça uma feature"
    And o usuário esteja logado como aluno
    When ele ver a sua lista de questões 
    Then a lista irá conter "Faça uma feature"

Scenario: responder logado como professor
    Given que as questões só podem ser respondidas pelos alunos
    And o professor esteja logado
    When estiver na página de questões dissertativas
    Then não irão aparecer as questões para serem respondidas

#GUI

Scenario: aparecer questoes para responder 
    Given que esteja logado como aluno
    And esteja no menu de questões dissertativas
    And a questão "Criar um feature" não foi respondida
    Then a questão "Criar um feature" irá aparecer na tela

Scenario: listar questões respondidas  
    Given que o aluno esteja logado
    And o sistema contenha a questão respondida "Como criar seu GitHub"
    And esteja no menu de questões dissertativas
    When selecionar a aba de questões respondidas
    Then a lista irá conter "Como criar seu GitHub"

Scenario: listar respostas dos alunos
    Given que o professor esteja logado
    And esteja no menu de questões dissertativas
    And seleciona a aba de questões respondidas
    When seleciona a opção de ver as respostas dos alunos
    Then a lista contem todas as respostas dos alunos

#Controle

Scenario: adicionar uma resposta 
    Given que o aluno esteja logado no sistema
    And tenha questões dissertativas para serem respondidas 
    When ele adicionar uma resposta para a questão
    Then a resposta será salva no sistema 

Scenario: listar respostas dos alunos
    Given que o professor esteja logado no sistema 
    And a questão "O que é Branch ?" já foi respondida 
    When professor vizualizar a lista 
    Then irá conter na lista a resposta da questão "O que é Branch?"

#GUI

Scenario: responder questões
    Given aluno esteja logado no sistema
    And esteja na aba de questões não respondidas
    When o aluno preencher a resposta da questão 
    And selecionar o botão de enviar 
    Then a resposta será armazendada no sistema

Scenario: listar questões não respondidas 
    Given aluno esteja logado no sistema
    And está no menu de questões dissertativas
    When ele seleciona a aba de questões não respondidas
    Then verá a lista de todas as questões não respondidas

#Erro

Scenario: enviar resposta em branco 
    Given aluno respondeu uma questão
    And deixa todo o campo de resposta em branco 
    When aluno tenta enviar questão
    Then questão não será salva no sistema


   