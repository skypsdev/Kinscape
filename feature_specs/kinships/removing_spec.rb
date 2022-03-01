require 'spec_helper'

feature 'Kinship removing', :js do
  let(:connector) { create :user, subscription: active_subscription }
  let(:active_subscription) { build :subscription, status: 'active' }
  let(:user) { create :user }
  let(:family) do
    create :family, name: 'Some family',
                    connector: connector,
                    users: [connector, user]
  end

  context 'when user is a connector' do
    background do
      visit "/communities/#{family.id}/kinships?as=#{connector.id}"
    end

    xscenario 'removes a user from the family' do
      expect(page).to have_css '.family-members', text: user.name

      user_item = page.all('.family-member')[1]
      user_item.hover
      expect(user_item).to have_css '.remove'

      click_on 'Remove from Family'

      expect(page).to have_text 'Are You Sure?'

      click_on 'OK'
      expect(page).to have_no_css '.family-members', text: user.name
    end

    scenario 'can not remove himself' do
      expect(page).to have_css '.family-members', text: connector.name

      user_item = page.all('.family-member')[0]
      user_item.hover

      expect(user_item).to have_no_css '.remove'
    end
  end

  context 'when user is a family member' do
    scenario 'can not remove a family' do
      visit "/communities/#{family.id}/kinships?as=#{connector.id}"

      expect(page).to have_no_css '.remove-kinship'
    end
  end
end
