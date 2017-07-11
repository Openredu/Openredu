@i9n
	Feature: Free subscription configuration

	As a course admin
	I want to set free the access to some courses
	So that users get access to the course content freely

	# === CONTROLLER ===

	Scenario: creating a free course
	Given I'm creating a new course
	And I'm choosing the subscription price
	When I choose the free option
	Then the course is saved as free

	Scenario: creating a course with price zero
	Given I'm creating a new course
	And I'm choosing the subscription price
	And I choose the mensual subscription
	When I set the course price as zero
	Then the course is saved as free

	Scenario: changing the subscription mode from payable to free
	Given I'm in the configuration page of a course
	When I choose the free subscription option
	Then the course is saved as free

	Scenario: changing the subcription mode from payable to free, by filling the price field with zero
	Given I'm in the configuration page of a course
	When I fill the price field with zero
	Then the course is saved as free

	Scenario: change the subscription mode from free to payable
	Given I'm in the configuration page of a course
	When I select the mensual subscription option
	And I fill the price field with a non positive number
	Then the course is saved as payable

	Scenario: Informing user who subscribed to a payable course that it turned to free
	Given a course subscription mode is payable
	When the subscription mode changes to free
	Then a notification is sent to every subscriber to let him know about the change

	
	Scenario: Informing user who subscribed to a free course that it turned to payable
	Given a course subscription mode is free
	When the subscription mode changes to payable
	Then the access of every subscriber is blocked
	And a notification is sent to let them know about the change

	Scenario: opção de tornar o curso com “Assinatura Mensal” para “Assinatura Gratuita” para todos os usuários cadastrados no curso
	# maybe we should develop a bit this part : is there student bolsistas in the current system ? 
	# if yes, maybe we should give more flexibility to the system, the option to choose which student won't pay
	# even if at first we don't have enough time to implement it ;)
	# As I'm a lazy man, I let you implement that dudes haha
	Given eu estou nas configurações de assinatura do curso
	When eu seleciono a opção "Adicionar Bolsistas"
	And seleciono a opção "Selecionar todos os alunos"
	Then todos os alunos matriculados no curso agora possuem uma "Assinatura Gratuita" no mesmo


	# === GUI ===


	Scenario: creating a payable course
	Given I'm creating a new payable course
	And I'm at the pricing step
	When I choose the payable subscription option
	Then the price field is displayed

	Scenario: creating a free course
	Given I'm creating a new free course 
	And I'm at the pricing step
	When I choose the free subscription option
	Then the price field is hidden

	Scenario: I'm trying to create a course without filling the course price field
	Given I'm creating a new course
	And I'm choosing the subscription price
	When I try to go to the next step without filling the price field
	Then an error message is raised : to continue, you need to inform the price of this course

	Scenario: changing the subscription mode
	Given I'm in the configuration page of a course
	And I'm changing its subscription mode
	When I confirm the change
	Then a change notification appears, informing about the new subscription mode