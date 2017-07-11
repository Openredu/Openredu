@i9n

    Feature: Questões argumentativas
        As a professor cadastrado na plataforma
        I want do criar, remover, editar, listar e buscar questões existentes
        So that poderei assim apresenta-las em paginas web mostrando seu conteúdo

    Scenario: nova questão argumentativa
        Given que não existe uma questão argumentativa com enunciado "Quem foi romulo e remulo?"  e com assunto "História" no sistema
        When  eu crio uma questão argumentativa com enunciado "Quem foi Rômulo e remulo" e com assunto "História"
        Then  salve no sistema a nova questão argumentativa com enunciado "Quem foi romulo e remulo?"" e com assunto "História"

    Scenario: remover questão argumentativa existente
        Given que existe uma questão argumentativa com enunciado "Quem foi romulo e remulo?" no sistema
        When  eu removo a questão argumentativa com enunciado "Quem foi Rômulo e remulo"
        Then a questão argumentativa com enunciado "Quem foi Rômulo e remulo?" não existe mais no sistema

     Scenario: editar questão argumentativa existente
        Given que a questão argumentativa com enunciado "Quem foi romulo e remulo?" exite no sistema
        When  eu modifico o enunciado da questão argumentativa atual por "Quem foi castor?" ou o assunto "História"
        Then  será salvo no sistema a atualização dessa questão argumentativa

    Scenario: listar questões argumentativas existentes
        Given que tenha no sistema a questão argumentativa com enunciado "Quem foi romulo e remulo?"
        When eu vejo a lista de questões argumentativas
        Then  minha lista de questões argumentativas contêm a questão argumentativa com enunciado "Quem foi romulo e remulo"

    Scenario: buscar questões argumentativas existentes pesso enunciado
        Given que tenha no sistema a questão argumentativa com enunciado "Quem foi romulo e remulo?"
        When  eu busco uma questão argumentativa pelo seu enunciado
        And que o enunciado contenha a palavra "romulo"
        Then  a lista de questões argumentativas buscadas contem a questão com enunciado "Quem foi romulo e remulo?"

    Scenario: nova questão argumentativa web
        Given que estou no menu de questões
        When eu seleciono a opção "Questão argumentativa" no menu de questões
        And eu seleciono nova questão argumentativa na página de questões
        Then eu posso ver os detalhes da questão argumentativa

    Scenario: Questão com mesmo enunciado

        Given o professor "Adalberto" estiver logado no sistema redu
        And ter escrito o enunciado de uma questão para prova de "Anatomia" igual a outra da mesma prova
        When "Adalberto" tentar enviar a prova
        Then emita uma mensagem de erro "existe uma questão igual a outra em sua prova"

    Scenario: Upload de imagem de baixa qualidade

        Given o professor "Scoob" logado no sistema redu
        And fazer o upload de uma foto para uma questão da prova "Biologia Parte I"
        And o tamanho da foto for menor que o tamanho "5"
        When "Scoob" clicar em salvar
        Then emita uma mensagem de erro "o tamanho mínimo de um arquivo de foto é 5 kbs"

    Scenario: Questão sem enunciado

        Given o professor "Alberto" logado no sistema
    And na tela de criação de provas
        And deixar o questionário da prova vazio
        When "Alberto" for salvar a prova
        Then emita uma mensagem de erro "digite alguma questão/conteúdo para sua prova"