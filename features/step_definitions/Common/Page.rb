Given(/^I am at the "(.*?)" page$/) do |page_name|

  @page = PagesSupport.get_page(page_name).load
  expect(@page).to be_displayed
end

Then(/^I should be on the Home page for user "(.*?)"$/) do |username|
  @page = PagesSupport.get_page("Home").load(username: username)

  expect(@page).to be_displayed(username: username)
end

Then(/^I should be on the "(.*?)" page$/) do |pageName|
  @page = PagesSupport.get_page(pageName).load

  expect(@page).to be_displayed()
end
