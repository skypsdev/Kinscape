# frozen_string_literal: true

require 'spec_helper'

feature 'Intercom', :js do
  context 'for logged out user' do
    context 'help icon' do
      scenario 'is not visible on home page' do
        visit root_path

        expect(page).to_not have_css('#Intercom')
      end

      scenario 'is not visible on sign in page' do
        visit sign_in_path

        expect(page).to_not have_css('#Intercom')
      end
    end
  end

  context 'for logged in user' do
    let(:user) { create :user }

    background do
      allow(Global.intercom).to receive(:enabled).and_return(true)
      visit stories_path(as: user)
    end

    scenario 'element with #Intercom id triggering widget is present' do
      expect(page).to have_css('#Intercom')
    end
  end
end
