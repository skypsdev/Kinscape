# frozen_string_literal: true

require 'spec_helper'

feature 'User deletion', :js do
  let(:connector) { create :user, subscription: active_subscription }
  let(:active_subscription) { build :subscription, status: 'active' }
  let(:family_member) { create :user }

  let(:family) do
    create :family, connector: connector, users: [connector, family_member]
  end

  let(:kinship) { family.kinship_for(family_member) }

  background do
    visit kinship_mylife_profile_path(kinship, as: connector)

    page.find('a', text: t('families.remove_member')).click
  end

  context 'when confirmed' do
    scenario 'removes family member from family' do
      within '.confirmation-dialog' do
        click_on 'OK'
      end

      expect(page).to have_text(connector.name)
      expect(page).to have_no_text(family_member.name)
    end
  end

  context 'when confirmation declined' do
    scenario 'removes family member from family' do
      within '.confirmation-dialog' do
        click_on 'Cancel'
      end

      expect(page).to have_text(family_member.name)
      expect(page).to have_text t('families.remove_member')
      expect(page).to have_current_path(
        kinship_mylife_profile_path(kinship),
        ignore_query: true
      )
    end
  end
end
