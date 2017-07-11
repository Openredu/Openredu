Given(/'^estou cadastrando um novo curso $/) do 
	OpenRedu.curso.new = curso
	
end
Given(/'^eu escolho a opção “Assinatura mensal” $/) do
	OpenRedu.curso.find(curso).assinatura.tipo = mensal
	
end
When(/'^eu digito o preço como zero $/) do
	assert_equal( curso.assinatura.preço, 0, '')	
	
end
Then(/'^a opção de pagamento do curso é salva como “Gratuito” $/) do
	OpenRedu.curso.find(curso).assinatura.tipo = gratuito;
	
end





Given(/'^Given não existe curso gratuito X $/) do 
	curso = OpenRedu.curso.find(X)
	assert_nil curso
	
end
When(/'^eu cadastro um novo curso com valor de assinatura "gratuito" $/) do 
	OpenRedu.curso.find(X).assinatura.tipo = Gratuito
	assert_equal( curso.find(X).assinatura.tipo, Gratuito, '')
end
Then(/'^ o curso gratuito X é criado $/) do 
	assert_not_nil curso
end
