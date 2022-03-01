require 'spec_helper'

feature 'User Auth', :js do
  before do
    stub_mandrill
  end

  scenario 'signed out user is redirected to landing page' do
    visit stories_path

    expect(page).to have_current_path(sign_in_path)
  end

  context 'sign up' do
    before do
      plan = double('plan')
      allow(Stripe::Plan).to receive(:retrieve).and_return(plan)
      allow(plan).to receive(:amount).and_return(1999)
      allow(plan).to receive(:interval).and_return('year')
      allow(plan).to receive(:trial_period_days).and_return(90)

      visit root_path

      within '.homepage-top-block' do
        click_on 'Try it Free'
      end

      expect(page).to have_current_path(sign_up_path)

      fill_in 'First Name', with: 'Jake'
      fill_in 'Last Name',  with: 'Miller'
      fill_in 'Email',      with: 'jake.miller@example.com'
      fill_in 'Password',   with: 'password'
    end

    # Temp. remove payment feature
    # scenario 'a new account is registered' do
    #   click_button 'Start 3-month free trial'

    #   expect(User.last.email).to eq 'jake.miller@example.com'
    # end

    # context 'after sign up' do
    #   scenario 'the confirmation email has been sent' do
    #     click_button 'Start 3-month free trial'

    #     expect(ActionMailer::Base.deliveries.count).to eq 1
    #   end

    #   scenario 'user is redirected to the sign in page' do
    #     click_button 'Start 3-month free trial'

    #     expect(page).to have_current_path(sign_in_path)
    #   end

    #   scenario 'confirmation email flash appears' do
    #     click_button 'Start 3-month free trial'

    #     expect(flash).to have_text 'Just one more step'
    #   end
    # end
  end

  context 'user signs in' do
    let(:user) { create :user }

    before do
      visit root_path

      expect(page).not_to have_link 'Resend Activation Email'

      within 'header.global-header' do
        click_on 'Sign in'
      end

      allow(Billing::SubscriptionService).to receive(:subscribe)
    end

    context 'with invalid password' do
      before do
        fill_in 'Email',    with: user.email
        fill_in 'Password', with: 'invalid-password'
      end

      scenario 'user fails to log in' do
        click_button 'Sign in'

        expect(flash).to have_text I18n.t('flashes.failure_after_create')
      end
    end

    context 'unconfirmed email' do
      let(:user) { create :user, confirmed_at: nil }

      before do
        fill_in 'Email',    with: user.email
        fill_in 'Password', with: 'password'
      end

      scenario 'user fails to log in' do
        click_button 'Sign in'

        expect(page).not_to have_current_path(stories_path)
      end

      scenario 'user can resend the activiation email' do
        click_button 'Sign in'

        expect(page).to have_link 'Resend Activation Email'
      end
    end

    context 'confirmed email' do
      before do
        fill_in 'Email',    with: user.email
        fill_in 'Password', with: 'password'
      end

      # Temp. remove payment feature
      # context 'when the user is not subscribed yet' do
      #   scenario 'user is subscribed to the trial plan' do
      #     expect(Billing::SubscriptionService).to receive(:subscribe)

      #     click_button 'Sign in'
      #   end
      # end

      scenario 'user is redirected to stories page after sign in' do
        click_button 'Sign in'

        expect(page).to have_current_path(stories_path)
      end
    end
  end
end
