require 'spec_helper'

feature 'Adding a ward to a family', :js do
  let(:user) { create :user, subscription: active_subscription }
  let(:active_subscription) { build :subscription, status: 'active' }

  let(:family) do
    create :family, name: 'The Smiths',
                    connector: user,
                    users: [user]
  end

  before do
    visit '/'
    visit "/communities/#{family.id}/kinships?as=#{user.id}"
    dismiss_cookieconsent
    find('.open-invite-modal', match: :first).click
  end

  scenario 'add a new family member without email' do
    find('.boolean-group a.submit').click

    expect(page).to have_text 'The Smiths Family'

    fill_in 'Name', with: 'Tom'

    click_on 'Create Profile'

    expect(page).to have_text 'The Smiths Family'
    expect(page).to have_text 'Tom'
  end
end
