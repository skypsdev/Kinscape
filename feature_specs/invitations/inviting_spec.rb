require 'spec_helper'

feature 'Inviting to family', :js do
  let(:user) { create :user }

  let(:family) do
    create :family, name: 'Some family',
                    connector: user,
                    users: [user]
  end

  before do
    stub_mandrill
    visit "/communities/#{family.id}/kinships?as=#{user.id}"
    find('.open-invite-modal', match: :first).click
    expect(page).to have_text 'Invite Family Members'
  end

  scenario 'invite a new family member' do
    find('.vs__search').set('new@example.com')

    click_on 'Send invitations'

    # expect(page).to have_text 'invited to Family'
    click_on 'Invitations'

    within '.family-members li:nth-child(1)' do
      expect(page).to have_text 'new@example.com'
      expect(page).to have_text 'Invited'
    end
  end

  scenario 'invite an existing user' do
    create(
      :user,
      email: 'existing@example.com',
      first_name: 'John',
      last_name: 'Snow'
    )

    find('.vs__search').set('existing@example.com')

    click_on 'Send invitations'

    # expect(page).to have_text 'invited to Family'

    within '.family-members li:nth-child(2)' do
      expect(page).to have_text 'John Snow'
      expect(page).to have_no_text 'Invited'
    end
  end
end
