require 'spec_helper'

feature 'Invitations accepting', :js do
  let(:connector)   { create :user }
  let(:family)      { create :family, connector: connector }
  let!(:invitation) do
    create :invitation,
           family: family,
           sender: connector,
           email: 'test@example.com'
  end

  before do
    create :attic, family: family, user: connector

    family.users += create_pair :user

    stub_mandrill

    visit family_invitation_path(family, invitation)

    dismiss_cookieconsent
  end

  scenario 'recipient accepts invitation' do
    fill_in 'First Name', with: 'Test'
    fill_in 'Last Name',  with: 'User'
    fill_in 'Email',      with: 'test@example.com'
    fill_in 'Password',   with: 'password'

    click_on 'Accept invitation'

    expect(page).to have_current_path(
      "/communities/#{invitation.family.id}/kinships"
    )
    expect(page).to have_css '.family-members', text: 'Test User'
    expect(page).not_to have_text 'Invited'
    expect(all_emails.size).to eq 0
  end
end
