# frozen_string_literal: true

require 'spec_helper'

feature 'Families updating', :js do
  include FamiliesPageHelpers

  let(:user) { create :user, subscription: active_subscription }
  let(:active_subscription) { build :subscription, status: 'active' }

  background do
    @family = create :family, name: 'Original family name',
                              connector: user,
                              users: [user]

    visit families_path(as: user)

    click_on 'Original family name'

    expect(page).to have_current_path("/communities/#{@family.id}/edit")
    expect(page).to have_css '#family-info'
  end

  scenario 'update family settings' do
    fill_contenteditable '#family_name', 'New family name'
    fill_contenteditable '#family_motto', 'Family motto'

    expect_saved_status
  end

  scenario 'change cover image' do
    # TODO: pending 'Figure out how to upload images on vue with capybara'
  end
end
