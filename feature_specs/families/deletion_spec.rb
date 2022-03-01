require 'spec_helper'

feature 'Families deletion', :js do
  let!(:connector) { create :user, subscription: active_subscription }
  let(:active_subscription) { build :subscription, status: 'active' }

  let!(:family) do
    create :family, name: 'Smith', connector: connector, users: [connector]
  end

  let!(:story) { create :story, user: connector, families: [family] }

  background do
    visit families_path as: connector
  end

  scenario 'successfully deleted' do
    click_on 'Smith'
    click_on 'Profile'
    click_on 'Delete Family'

    within '.confirmation-dialog' do
      click_button 'OK'
    end

    # expect(page).to have_no_text 'Smith'
    expect(page).to have_current_path('/communities')
  end

  context 'when family has family members' do
    background do
      create(:user, families: [family])
    end

    scenario 'user does not see delete button' do
      click_on 'Smith'

      expect(page).to have_no_link 'Delete Family'
    end
  end
end
