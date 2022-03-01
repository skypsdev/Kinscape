require 'spec_helper'

feature 'Invitations', :js do
  let(:connector) { create :user, subscription: active_subscription }
  let(:active_subscription) { build :subscription, status: 'active' }
  let(:family) { create :family, connector: connector, users: [connector] }
  let(:invitation) { create :invitation, family: family }

  context 'when user is a connector' do
    scenario 'cancel an unaccepted invitation' do
      visit "/communities/#{invitation.family.id}/invited?as=#{connector.id}"
      expect(page).to have_css '.family-members', text: invitation.email

      page.find('.family-member.invited').hover
      click_on 'Cancel invitation'

      # expect(flash).to have_text 'has been canceled'
      expect(page).to have_no_css '.family-members', text: invitation.email
    end
  end

  context 'when user is a family member' do
    let(:user) { create :user, families: [family] }

    scenario 'can not cancel an invitation' do
      visit "/communities/#{invitation.family.id}/invited?as=#{user.id}"

      expect(page).to have_no_text 'Cancel invitation'
    end
  end
end
