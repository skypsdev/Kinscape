require 'spec_helper'

feature 'Email confirmation', :js do
  context 'invalid token' do
    scenario 'user is redirected to sign up page' do
      visit confirm_email_path(token: 'invalid_token')

      expect(page).to have_current_path(root_path)
    end
  end

  context 'valid token' do
    before do
      create :user, confirmation_token: 'valid_token'
    end

    # Temp. remove payment feature
    # scenario 'user is subscribed to the trial plan' do
    #   expect(Billing::SubscriptionService).to receive(:subscribe)

    #   visit confirm_email_path(token: 'valid_token')
    # end

    scenario 'user is signed in and redirected to welcome page' do
      # allow(Billing::SubscriptionService).to receive(:subscribe)

      visit confirm_email_path(token: 'valid_token')

      expect(page).to have_current_path(welcome_path)
      # expect(flash).to have_text 'Free trial successfully activated!'
    end
  end
end
