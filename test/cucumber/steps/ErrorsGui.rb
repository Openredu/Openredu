#GUIErros

Given(/^que eu estou na tela de criação de provas$/) do
  to LoginTeacher
  at LoginTeacher
  page.fillLoginData(user,"teachersenha")
  visit PageProva
end

Given(/^eu escrever o enunciado de uma questão para prova de "([^"]*)" igual a o
utra da mesma prova$/) do |p1|
  @questao = Questao.find_by_enunciado_semelhante ! ("p1")
  assert(questaoSemelhante(p1,p2), "As questões são semelhantes")
end

When(/^eu clico em "([^"]*)"$/) do
  at PageProva
  page.clickSave()
  at PageProvaSave
end

Then(/^o sistema emite uma mensagem de erro "([^"]*)"$/) do
	assert_not_equal(p1,p2,msg="Você digitou duas questões com o mesmo enunciado!")
	at PageProva
  
end

Given(/^que eu estou na página de criação de provas$/) do
  to LoginTeacher
  at LoginTeacher
  page.fillLoginData(user,"teachersenha")
  visit PageProva
end

When(/^eu deixar o questionário da prova vazio$/) do |questionario|
	campodequestoes = assert_nil questionario
	assert_nil campodequestoes
end

Then(/^o sistema exibe uma mensagem de erro "([^"]*)"$/) do |questionario|
  assert(campodequestoes, msg= "Prova sem questionário!")
	at PageProva
end