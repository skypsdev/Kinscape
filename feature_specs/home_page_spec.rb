require 'spec_helper'

feature 'Home page', :js do
  context 'logged in user' do
    scenario 'can not visit home page' do
      user = create :user

      visit families_path as: user

      first('.logo').click

      expect(page).to have_current_path(stories_path)
    end
  end
end
