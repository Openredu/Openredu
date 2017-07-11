#controller
Given(/'^ o sistema tem a questão "([^"]*)" respondida $/) do |title|
		question = Questions.find_by_title(title)
		response = Questions.find_by_response(question.response)
		assert_not_nil response
end
Given(/'^ eu estou logado como "aluno"$/) do 
	user = UserAluno.find_by_name(name)
	assert UserAlunoData.containsUser(user)
end
When(/'^ eu vejo a lista de questões respondidas $/) do 
	question = Questions.findResponseQuestion()
	assert_not_nil question
end
Then(/'^ a lista de questões respondidas contém a questão "([^"]*)"$/) do |title|
 	assert_not_nil question.find_by_title(title)
end

#GUI
Given(/'^ que o "aluno" esteja logado$/) do 
	to LoginPage
	at LoginPage
	page.fillLoginData(userName, “password”)
end
Given(/'^ o sistema contenha a questão respondida  "([^"]*)"$/) do |title|
	question = QuestionData.find_by_title(title)
	assert_not_nil question
end
Given(/'^ esteja no menu de questões dissertativas $/) do 
	visit questions_path
end
When(/'^ selecionar a aba de questões respondidas $/) do 
	at QuestionShowPage
	page.clickQuestoesRespondidas()
	to QuestionResponse
end
Then (/'^ a lista irá conter "([^"]*)"$/) do |title|
	at QuestionResponse
	assert QuestionData.containsQuestionResponse(quetion)
end