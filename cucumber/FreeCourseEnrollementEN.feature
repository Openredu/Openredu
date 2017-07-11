@i9n
	Feature: subscribe to free courses
	
	As a common user
	I want to subscribe to a free course
	So that I get access to the course content

	# === CONTROLLER ===

	Scenario: subscribe to a course
	Given I'm subscribing to a course
	And the course is saved as free
	When I confirm the subscription
	Then the subscription is approved

	Scenario: cancelling a subscription
	Given I've subscribe to a course
	When i choose to cancel my subscription
	Then the subscription is cancelled

	Scenario: course setting changes
	Given I've subscribed to a course
	And the course configuration is changed into mensual subscription
	Then my subscription is blocked

	Scenario: cancel subscription to an initially free course
	Given I've subscrided to a course which configuration was initially free
	And the course configuration has changed into mensual subscription
	When I choose to cancel my subscription
	Then my subscription to this course is canceled

	Scenario: paying an initially free course
	Given I've subscrided to a course which configuration was initially free
	And the course configuration has changed into mensual subscription
	When my payment is confirmed
	Then my subscription to this course is unblocked

	# === GUI ===

	Scenario: subscribe to a free course
	Given I'm subscribing to a free course
	When I confirm the subscription
	Then the subscription is directly approved, without passing by a paying interface

	Scenario: course configuration changed from free to payable
	Given I've subscrided to a course which configuration was initially free
	And the course configuration has changed into mensual subscription
	When I want to access to the course
	Then an interface in which I can choose whether i want to pay or cancel appears
