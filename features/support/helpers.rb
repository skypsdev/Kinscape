module Helpers
  def create_test_user_account
    visit sign_up_path
    fill_in 'user_first_name', with: 'USER'
    fill_in 'user_last_name', with: 'TEST'
    fill_in 'user_email', with: 'user0@test.com'
    fill_in 'user_password', with: 'test_password'
    fill_in 'user_password_confirmation', with: 'test_password'
    find('.custom-checkbox__checkmark').set(true)
    click_button 'Submit'
  end

  def confirm_test_user_account
    user = User.find_by email: 'user0@test.com'
    visit confirm_email_path(token: user.confirmation_token)
    visit sign_out_path
  end

  def authenticate_test_user_account
    create_test_user_account
    confirm_test_user_account
    visit sign_in_path
    fill_in :session_email, with: 'user0@test.com'
    fill_in :session_password, with: 'test_password'
    click_button 'Log In'
  end

  def click_member_tile(name)
    find('a', text: name).click
  end
end
