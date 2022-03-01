require 'spec_helper'

feature 'Invitations resending', :js do
  let(:connector)  { create :user, subscription: active_subscription }
  let(:family)     { create :family, connector: connector, users: [connector] }
  let(:invitation) { create :invitation, family: family }
  let(:active_subscription) { build :subscription, status: 'active' }

  before do
    stub_mandrill
  end

  context 'when user is a connector' do
    scenario 'resend an invitation' do
      visit "/communities/#{invitation.family.id}/invited?as=#{connector.id}"
      page.find('.family-member.invited').hover
      click_on 'Resend invitation'

      # expect(page).to have_content('invited to Family')
    end
  end

  context 'when user is a family member' do
    let(:user) { create :user, families: [family] }

    scenario 'can not resend an invitation' do
      visit "/communities/#{invitation.family.id}/kinships?as=#{user.id}"

      expect(page).to have_no_text 'Resend invitation'
    end
  end
end
