Then /^I should have received a password redefinition request via the "(.*?)" email$/ do |email|
  ask("Did the password redefinition request have been received on the #{email} email? [Yes/No]", 10)
  .chomp.should =~ /yes/i
end

When /^I fill the email field with "(.*?)"$/ do |email|
  @page = @page.fillEmailField(email)
               .submitEmail
end
