Feature: Integração do sistema Openredu e Inovaula Steps
	As a Usuário do Openredu
	I want to poder associar os conteúdos da disciplina que estou estudando no OpenRedu à 
	conteúdos de mesma área presentes no Inovaula 
	so that poder linkar esses conteúdos relacionados a uma disciplina.

#CONTROLLER
Scenario: Nova disciplina
	Given	Que o usuário está registrando a disciplina “Grandezas e Unidades”
	When	Ele estiver preenchendo os campos com as informações da disciplina
	Then	Ele poderá linkar um plano de aula do Inovaula àquela disciplina

Scenario: Modificação de Conteúdo
	Given	Que o aluno "Eduardo" está estudando o assunto “Grandezas e Unidades”
	When	O usuário procurar o plano de aula do tema “Grandezas e Unidades” e quiser modificar este plano
	Then	Ele poderá enviar uma solicitação para o autor daquela aula para modificar o plano existente.
	And 	O autor receberá um email avisando da solicitação, que será avaliada e aceita/não aceita.

Scenario: Planos Sugeridos
	Given	Que um usuário está estudando o assunto “Grandezas e Unidades”
	When	O usuário estiver procurando o plano de aula dessa disciplina
	Then	Ele encontrará também os planos sugeridos por outros usuários. 

Scenario: Listagem de planos Sugeridos
	Given 	Que aluno "Eduardo" está estudando o assunto “Grandezas e Unidades”
	When	O usuário estiver olhando os planos de aula sugeridos relacionados a essa disciplina
	Then	Ele poderá visualizar esses planos e os que tiverem mais upvotes serão listados mais a frente do que os que tiverem menos upvotes

#GUI
Scenario: Votação de planos Sugeridos
	Given	Que um usuário está na pagina de planos sugeridos
	When 	O usuário votar no plano de aula "Grandezas e unidades com o professor Edu"
	Then 	Ele verá a mensagem "Voto realizado" confirmando o voto

Scenario: Sugestão de planos novos
	Given	Que o aluno "Eduardo" está na pagina do assunto “Grandezas e Unidades”
	When	O usuário achar que um plano de aula do inovaula é bom para os alunos estudarem 
	Then	Ele poderá colocar o link do plano de aula na barra "Sugira um plano" 
	And 	clicar no botão "Sugerir" para enviar a sugestão para o autor da aula


Scenario: Sugestão de planos duplicados
	Given	Que o aluno "Eduardo" está na página do assunto “Grandezas e Unidades”
	When	O usuário tentar sugerir um plano de aula já existente
	Then	Será aberta uma janela de notificação avisando que o plano de aula já está linkado àquela disciplina