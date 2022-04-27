Given(/^I have an active user account$/) do
  create_test_user_account
  confirm_test_user_account
end

Given(/^I am authenticated$/) do
  authenticate_test_user_account
end

When(/^I authenticate with valid account details$/) do
  visit sign_in_path
  fill_in :session_email, with: 'user0@test.com'
  fill_in :session_password, with: 'test_password'
  click_button 'Log In'
end

Then(/^I am presented with the onboarding dialog$/) do
  expect(page).to have_content 'Welcome to Kinscape!'
  expect(page).to have_css('div.welcome-dialog')
end

When(/^I fulfill onboarding dialog$/) do
  click_button 'Next'
  expect(page).to have_content 'Enjoy life in your Communities'
  click_button 'Next'
  expect(page).to have_content 'Share the stories that matter'
  click_button 'Next'
  expect(page).to have_content 'My Life'
  click_button 'Setup profile'
  fill_in "Enter your full name", with: 'test name'
  click_button "Create Profile"
  expect(page).to have_content 'Tour Kinscape here.'
  find('button.burger-button__close').click
end

Then(/^I am presented with the my life page$/) do
  expect(page).to have_css('div.profile')
  expect(page).to have_selector("button.select-profile__button")
end

When(/^I authenticate with invalid account details$/) do
  fill_in :session_email, with: 'INVALID@USER.COM'
  fill_in :session_password, with: 'YOUSHALLNOTPASS'
  click_button 'Log In'
end

Then(/^I am presented with an error message$/) do
  expect(page).to have_css 'div.badge--error'
end
