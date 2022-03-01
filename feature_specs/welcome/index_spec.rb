require 'spec_helper'

feature 'Welcome page', :js do
  let(:user) { create :user }

  background do
    visit welcome_path(as: user)
  end

  scenario 'shows basic action buttons' do
    expect(page).to have_link('Create a Family', href: new_family_path)
    expect(page).to have_link('Start a Story', href: stories_path)
  end

  scenario 'allows to send a message to other user' do
    find('.user-menu-toggle').click

    within '.current-user-menu' do
      expect(page).not_to have_text 'Send a Message'
    end

    within '.global-header' do
      click_on 'Message'
    end

    expect(page).to have_text 'Send A Message To Members'
    expect(page).to have_button 'Send message', disabled: true
  end
end
