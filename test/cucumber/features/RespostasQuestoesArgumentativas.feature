Feature: Respostas das Questões Argumentativas
    As a usuário esteja logado no sistema
    I want listar e adicionar respostas e  listar questões
    So that possa responder e analisar as questões dissertativas
  
    Scenario: adicionar uma resposta 
        Given eu esteja logado como "aluno"
        And a questão "Teste" ainda não foi respondida 
        When eu adicionar uma resposta para  "Teste"
        Then a resposta da questão "Teste"será salva no sistema 

    Scenario: listar "questões não respondidas" 
        Given eu esteja logado como "aluno"no sistema
        And estou no menu de questões dissertativas
        When eu selecionar a aba de "questões não respondidas"
        Then verei a lista de todas as "questões não respondidas"


