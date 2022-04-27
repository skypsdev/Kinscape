When(/^I confirm my account using my confirmation link$/) do
  open_email 'user0@test.com'
  current_email.click_link 'Confirm Email'
end
