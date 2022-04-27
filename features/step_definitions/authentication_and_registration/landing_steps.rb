When(/^I visit the homepage$/) do
  visit root_path
end

When(/^I visit the sign up page$/) do
  visit root_path
  RegistrationCode.create(code: 12345)
  fill_in :c1, with: 1
  fill_in :c2, with: 2
  fill_in :c3, with: 3
  fill_in :c4, with: 4
  fill_in :c5, with: 5
  click_button "Join Kinscape"
end

When(/^I visit the sign in page$/) do
  visit root_path
  click_link 'Log in'
end

Then(/^I am presented with the sign up page$/) do
  expect(page).to have_content('Create your Account')
  expect(page).to have_selector('form[action=\'/users\'][method=\'post\']')
end

Then(/^I am presented with the sign in page$/) do
  expect(page).to have_content('Forgot password?')
  expect(page).to have_selector('form[action=\'/session\'][method=\'post\']')
end
