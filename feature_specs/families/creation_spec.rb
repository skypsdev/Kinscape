# frozen_string_literal: true

require 'spec_helper'

feature 'Families creation', :js do
  let(:user)                        { create :user, subscription: subscription }
  let(:subscription)                { build :subscription, status: 'active' }
  let(:edit_family_path_expression) { %r{\/communities\/\d+\/edit$} }

  background do
    visit families_path(as: user)

    find('.submenu').click_link 'Add Family'
  end

  context 'valid family name' do
    scenario 'create new family' do
      fill_in 'Family Name', with: 'My new family'

      click_on 'Create family'

      expect(page).to have_css('h1', text: 'My new family')
      expect(current_path).to match(edit_family_path_expression)
    end
  end

  context 'invalid family name' do
    scenario 'create new family' do
      fill_in 'Family Name', with: ''

      click_on 'Create family'

      expect(page).to have_css('h2', text: 'Add Family')
      expect(page).to have_current_path(new_family_path)
    end
  end

  scenario 'click back button' do
    click_on 'Return to Familyscape'

    expect(page).to have_current_path(families_path)
  end
end
