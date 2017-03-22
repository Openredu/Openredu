When(/^I logout from the system$/) do
  @page = @page.logout
end

When(/^I clean the browser's cookies$/) do
  browser = Capybara.current_session.driver.browser
  if browser.respond_to?(:manage) and browser.manage.respond_to?(:delete_all_cookies)
    browser.manage.delete_all_cookies
  else
    ask("Please, delete the browser cookies and type yes:")
  end
end

When /^I reload the page$/ do
  @page.evaluate_script("window.location.reload()");
end

Then /^I should see the page access error message$/ do
  ask("Did the warning message appear? [Yes/No]", 10).chomp.should =~ /yes/i
end
