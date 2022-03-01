require 'spec_helper'

feature 'Reset password', :js do
  let(:user) { create :user, confirmation_token: 'valid_token' }

  context 'invalid token' do
    background do
      visit edit_user_password_path(user, token: 'invalid_token')
    end

    scenario 'user can\'t reset password' do
      expect(page).not_to have_text 'Change Your Password'
    end

    scenario 'user must enter the email again' do
      expect(page).to have_text 'Forgot Your Password?'
    end
  end

  context 'valid token' do
    let(:new_password) { 'password123' }

    background do
      visit edit_user_password_path(user, token: user.confirmation_token)
    end

    scenario 'user can see the reset password page' do
      expect(page).to have_text 'Change Your Password'
    end

    scenario 'user redirects to the stories page after reset' do
      fill_in 'password', with: new_password
      fill_in 'password_reset_password_confirmation', with: new_password

      click_button 'Update password'

      expect(page).to have_current_path(stories_path)
    end
  end
end
