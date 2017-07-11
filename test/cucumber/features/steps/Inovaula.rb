#Scenario: Unlink account
Given (/^You're logged on Inovaula as "<[^"]*>"$/) do |user|
	inovaulaAccount = InovaulaAccount.get(user.inovaula)
	assert InovaulaUserData.containsUser(inovaulaAccount)
end

When(/^Click on the remove unlink my account button/) do |user|
	InovaulaAccount.remove(user.inovaula)
	assert_equal(InovaulaAccount.get(user.inovaula), nil)
end
