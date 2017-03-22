When(/^I press on the "(.*?)" keyboard button$/) do |key|
  PagesSupport.press_key(@page, key)
end
