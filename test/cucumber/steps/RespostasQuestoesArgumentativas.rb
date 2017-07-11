Given (/^que eu esteja logado como "<[^"]*>"$/) do  |name|  
 
user = UserAluno.find_by_name(name)
assert UserAlunoData.containsUser(user)
end 
	
Given (/^ a questão "<[^"]*>" ainda não foi respondida$/)do  |title|
 question = Question.find_by_title(title)
 response = Question.find_by_response(question)
 assert_nil response
end

When (/^eu adicionar uma resposta para "<[^"]*>"$/) do   |question|

 QuestionsData.addResponse(question,response)
 
end


Then (/^a resposta da questão "<[^"]*>"será salva no sistema$/) do  |questao|
  QuestionsDate.saveResponse(response)
end

Given (/^que eu esteja logado como "<[^"]*>" no sistema$/) do     

to LoginAluno
at LoginAluno
page.fillLoginData(userName, "senhaAluno")
end
	

Given (/^ eu estou no menu de questoes dissertativas$/) do 

	visit question
endl

When (/^eu selecionar a aba de questões não respondidas$/)do 
    at QuestionShowPage
	page.clickQuestionNoResponse()
	at QuestionNoResponse
end

Then (/^verei a lista de todas as questões não respondidas$/) do 

    at QuestionNoResponse
	assert QuestionDate.containsQuestionNoResponse(page.questionNoResponse())
	page.selectViewAllQuestionsNoResponse()
end


