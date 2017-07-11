Given(/^Que o aluno "([^"]*)" está estudando o assunto "([^"]*)"$/) do |nomeUsuario, nomeDisciplina|
	user = UserAluno.find_by_name(nomeUsuario)
	disciplina = Disciplinas.find_by_name(nomeDisciplina)
end

When(/^O usuário estiver olhando os planos de aula sugeridos relacionados a essa disciplina$/) do
	planos = PlanosAula.get_all()
end
Then(/^Ele poderá visualizar esses planos e os que tiverem mais upvotes serão listados mais a frente do que os que tiverem menos upvotes$/) do
	planos.order_by_upvote()
end


Given(/^Que um usuário está na pagina de planos sugeridos$/) do
	to PlanosSugeridos
	at PlanosSugeridos
end
When(/^O usuário votar no plano de aula "([^"]*)"$/) do |nomePlano|
	page.clickUpvote(nomeBotao)
end
Then(/^Ele verá a mensagem "([^"]*)" confirmando o voto$/) do |mensagemConfirmacao|
	page.openPopup(mensagemConfirmacao)
end
