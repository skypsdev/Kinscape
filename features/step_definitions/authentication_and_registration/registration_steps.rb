When(/^I sign up using valid details$/) do
  create_test_user_account
end

When(/^I sign up using invalid details$/) do
  visit sign_up_path
  fill_in 'user_first_name', with: ''
  fill_in 'user_last_name', with: ''
  fill_in 'user_email', with: 'FAIL@TEST.COM'
  fill_in 'user_password', with: 'FAIL_TEST'
  click_button 'Submit'
end

When(/^I sign up using an email address already linked to an account$/) do
  create_test_user_account
  confirm_test_user_account

  visit sign_up_path
  fill_in 'user_first_name', with: 'SAME_EMAIL_USER'
  fill_in 'user_last_name', with: 'SAME_EMAIL_USER'
  fill_in 'user_email', with: 'user0@test.com'
  fill_in 'user_password', with: 'FAIL_TEST'
  click_button 'Submit'
end

Then(/^I am sent an email to confirm my email address$/) do
  open_email('user0@test.com')
  expect(current_email.subject).to eq 'Email confirmation instructions'
end

Then(/^I am informed of an error$/) do
  expect(page).to have_selector 'span.badge__message'
  expect(page).to have_content "Can't be blank"
end

Then(/^I am informed that the email address is already taken$/) do
  expect(page).to have_selector 'span.badge__message'
  expect(page).to have_content 'Has already been taken'
end
