When(/^I fill the username field with "(.*?)" and the password field with "(.*?)"$/) do |username, password|
  @page = @page.open_sign_in
               .log_with_username(username, password)
end

When(/^I click on the Submit button$/) do
  @page = @page.submit_login
end

Then(/^I should see the invalid password error message$/) do
  @page.invalid_password_display?.should be_true
end

Then(/^I should see the empty password error message$/) do
  @page.empty_password_display?.should be_true
end

Then(/^I should see the invalid username error message$/) do
  @page.invalid_username_display?.should be_true
end

Then(/^I should see the empty username error message$/) do
  @page.empty_username_display?.should be_true
end
