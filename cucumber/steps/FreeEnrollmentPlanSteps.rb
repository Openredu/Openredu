# language: en
#igor lira
#Scenario: Notificar os usuarios sobre a mudança na assinatura de um curso de "Gratuito" para "Mensal"
Given (/^que um curso "([^"]*)" tem assinatura gratuita $/) do |nome_curso|
	curso = Course.find(:name => nome_curso)
	assert_equal(curso.enrollment_type, 'free')
end

When(/^o curso "([^"]*)" é alterado para assinatura mensal$/) do |nome_curso|
	curso = Course.find(:name => nome_curso)
	assert_equal(curso.enrollment_type, 'monthly')
end

#igor, existe uma funcao chamada "send_blocked_notice" em https://github.com/OpenRedu/OpenRedu/blob/master/app/models/plan.rb que acho que serve para esse step
Then(/^bloqueia o acesso de todos os usuários cadastrados no curso "([^"]*)"$/) do |nome_curso|
	curso = Course.find(:name => nome_curso)
	curso.course_enrollments.each do |assinatura|
		assinatura.state = "waiting"
		assinatura.save
	end
end

And(/^notifica todos os usuários cadastrados no curso "([^"]*)" sobre a modificação da assinatura$/) do |nome_curso|
	curso = Course.find(:name => nome_curso)
	curso.course_enrollments.each do |assinatura|
		assinatura.notify_about_change
	end
end


#igor lira
#Scenario: opção de tornar o curso com “Assinatura Mensal” para “Assinatura Gratuita” para todos os usuários cadastrados no curso
Given(/^estou me cadastrando no curso "([^"]*)"$/) do |nome_curso|
	curso = Course.find(:name => nome_curso)
	assert_equal(current_page, 'course_enrollment')
	assert_equal(course_id, curso.id)
end

And(/^o curso "([^"]*)" foi cadastrado como “Gratuito”$/) do |nome_curso|
	curso = Course.find(:name => nome_curso)
	assert_equal(curso.enrollment_type, 'free')
end

When(/^eu confirmo minha inscrição no curso "([^"]*)"$/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	curso.join my_user
end

Then(/^minha inscrição no curso "([^"]*)" é automaticamente aprovada$/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	curso.join! my_user
end

#lucas biagini
#Scenario: Modificar assinatura de curso de “Mensal” para “Gratuito”
Given (/^estou na página de configurações da assinatura do curso "([^"]*)"$/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	assert_equal(current_page, 'enrollment_type')
end

When (/^eu seleciono a opção de assinatura do curso "([^"]*)" para “Gratuito”$/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	curso.set_enrollment_plan 'free'
end

And (/^eu confirmo as alterações no curso "([^"]*)"$/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	curso.set_enrollment_plan! 'free'
end

Then (/^o tipo da assinatura do curso "([^"]*)" é alterado para “Gratuito”$/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	curso.assert_equal(enrollment_type, 'free')
end

#lucas biagini
#Scenario: Modificar assinatura de curso de “Mensal” para “Gratuita”, dado que escolheu preço zero
Given (/estou na página de configurações da assinatura do curso "([^"]*)"/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	assert_equal(current_page, 'enrollment_type')
end

And (/o curso "([^"]*)" é um curso com assinatura "Mensal"/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	curso.set_enrollment_plan 'monthly'
end

When (/eu preencho com "[^0]" o valor do curso "([^"]*)"/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	curso.set_value '0'
end

And (/o sistema me pergunta se eu quero alterar o tipo de assinatura do curso "([^"]*)" para "Gratuito"/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	if system.confirm(:option, 'true') do
		curso.set_enrollment_plan 'free'
	end
end

Then (/o tipo de assinatura do curso "([^"]*)" é alterado para “Gratuito”/) do |nome_curso|
	curso = Course.find(:name = nome_curso)
	curso.assert_equal(enrollment_type, 'free')
end