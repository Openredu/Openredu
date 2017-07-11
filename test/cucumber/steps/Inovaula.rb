#Scenario: Remoção de links sem estar logado como administrador da disciplina
Given (/^Eu estou logado como "<[^"]*>"$/) do  |user|  
	user = Users.find_by_name(user.name)
	assert UserData.containsUser(user)
end 

When(/^eu clico na opção de "<[^"]*>" da disciplina no OpenRedu$/) do |nomeOpçao|
	page.clickOption(nomeOpçao)
end

Then (/^é exibida uma mensagem de erro “Você não tem as permissões necessárias para realizar esta ação”$/) do 
	page.showPopUpAcessDenied()
end

#Scenario: Remover link presente em uma disciplina no OpenRedu que redireciona para conteúdos do inovaula.
Given (/^Eu estou logado como "<[^"]*>" da disciplina "([^"]*)"$/) do  |user, nome_disciplina|  
	user = UsersAdmin.find_by_name(user.name)
	assert UserAdminData.containsUser(user)
	disciplina = Disciplinas.find(:name = nome_disciplina)
end

And(/^estou na página de "([^"]*)"$/) do |page|
	assert_equal(page, 'enrollment_type')
end

When(/^eu seleciono a opção Remover no menu da disciplina "([^"]*)"$/) do |nome_disciplina|
	disciplina = Disciplinas.find(:name = nome_disciplina)
	disciplina.setState(0)
end

Then (/^A disciplina "([^"]*) é removida$/) do |nome_disciplina|
	disciplina = Disciplinas.find(:name = nome_disciplina)
	if disciplina.State == 0
		disciplina.remove()
	end
end

