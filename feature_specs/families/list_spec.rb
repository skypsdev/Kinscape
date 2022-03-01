require 'spec_helper'

feature 'Families viewing', :js do
  include FamiliesPageHelpers

  let!(:mark_barkins) do
    create :user, first_name: 'Mark',
                  last_name: 'Barkins'
  end

  let!(:jake_purrkins) do
    create :user, first_name: 'Jake',
                  last_name: 'Purrkins'
  end

  let!(:murlo_purrkins) do
    create :user, first_name: 'Murlo',
                  last_name: 'Purrkins',
                  caretaker_id: jake_purrkins.id,
                  title: 'Murchyk'
  end

  let!(:purrkins) do
    create :family, name: 'Purrkins',
                    connector: jake_purrkins, # this seems useless?
                    users: [jake_purrkins, murlo_purrkins] # Connector is 1st
  end

  let!(:barkins) do
    create :family, name: 'Barkins',
                    connector: mark_barkins,
                    users: [mark_barkins]
  end

  background do
    @mark_sub = create :subscription, status: 'active', user: mark_barkins
    @jake_sub = create :subscription, status: 'active', user: jake_purrkins
    @murlo_sub = create :subscription, status: 'active', user: murlo_purrkins

    mark_barkins.families << purrkins
    jake_purrkins.families << barkins
    # workaround when '<<' above failed in R5.2 unless connector 1st in array
    # Kinship.create!(user_id: mark_barkins.id, family_id: purrkins.id)
    # Kinship.create!(user_id: jake_purrkins.id, family_id: barkins.id)
  end

  shared_examples 'submenu with families dropdown' do
    scenario 'can see families list' do
      expect(page).to have_css '.submenu__select'
    end
  end

  context 'where current user is just a family member' do
    background do
      visit families_path(as: mark_barkins)

      click_on 'Purrkins'
      click_on 'Members'
    end

    it_behaves_like 'submenu with families dropdown'

    scenario 'can not see family management buttons' do
      within 'ul.submenu' do
        expect(page).to have_no_link 'Add Family Members'
        expect(page).to \
          have_no_link(
            'Edit Family Settings',
            href: "/communities/#{barkins.id}/edit"
          )
      end
    end

    scenario 'can see family name and list of members' do
      family_name_present 'Purrkins'

      member_names_present 'Mark Barkins', 'Jake Purrkins', 'Murlo Purrkins'
    end

    scenario 'can see titles' do
      within "#user_#{jake_purrkins.id}" do
        expect(page).to have_text 'CONNECTOR'
      end

      within "#user_#{murlo_purrkins.id}" do
        expect(page).to have_text 'MURCHYK'
      end
    end
  end

  # Temp. remove payment feature
  # context 'when the current user is guest' do
  #   background do
  #     @mark_sub.update(
  #       status: 'past_due',
  #       trial_end: 10.days.ago
  #     )

  #     visit families_path(as: mark_barkins)
  #   end

  #   scenario 'can see guest button' do
  #     within 'ul.pad-right' do
  #       expect(page).to have_link 'Guest'
  #     end
  #   end

  #   context 'message button' do
  #     scenario 'can see message button' do
  #       within 'ul.pad-right' do
  #         expect(page).to have_link 'Message'
  #       end
  #     end

  #     context 'when click the message button' do
  #       background do
  #         within 'ul.pad-right' do
  #           click_on 'Message'
  #         end
  #       end

  #       scenario 'see the account upgrade modal' do
  #         within all('.confirmation-dialog')[0] do
  #           expect(page).to have_text t('account.upgrade_account_confirm.title')
  #         end
  #       end
  #     end
  #   end

  #   context 'start story button' do
  #     scenario 'can see start story button' do
  #       within 'ul.pad-right' do
  #         expect(page).to have_text 'Start a Story'
  #       end
  #     end

  #     context 'when click the start story button' do
  #       background do
  #         within 'ul.pad-right' do
  #           find('.new-story').click
  #         end
  #       end

  #       scenario 'see the account upgrade modal' do
  #         within all('.confirmation-dialog')[0] do
  #           expect(page).to have_text t('account.upgrade_account_confirm.title')
  #         end
  #       end
  #     end
  #   end

  #   scenario 'can not see family management buttons' do
  #     within 'ul.submenu' do
  #       expect(page).to have_no_link 'Add Family Members'
  #       expect(page).to \
  #         have_no_link(
  #           'Edit Family Settings',
  #           href: "/families/#{barkins.id}/edit"
  #         )
  #     end
  #   end
  # end

  # Temp. remove payment feature
  # context 'when the current user is trialing' do
  #   background do
  #     @mark_sub.update(
  #       status: 'trialing',
  #       trial_end: Time.now + 10.days
  #     )

  #     visit families_path(as: mark_barkins)
  #   end

  #   scenario 'can see trial button' do
  #     within 'ul.pad-right' do
  #       expect(page).to have_link \
  #         t(
  #           'subscriptions.upgrade_with_trial_days',
  #           day: mark_barkins.subscription.trial_days
  #         )
  #     end
  #   end

  #   context 'message button' do
  #     scenario 'can see message button' do
  #       within 'ul.pad-right' do
  #         expect(page).to have_link 'Message'
  #       end
  #     end

  #     context 'when click the message button' do
  #       background do
  #         within 'ul.pad-right' do
  #           click_on 'Message'
  #         end
  #       end

  #       scenario 'see the message modal' do
  #         within first('.request-story-modal') do
  #           expect(page).to have_text 'Send A Message To Members'
  #         end
  #       end
  #     end
  #   end

  #   context 'start story button' do
  #     scenario 'can see start story button' do
  #       within 'ul.pad-right' do
  #         expect(page).to have_text 'Start a Story'
  #       end
  #     end

  #     context 'when click the start story button' do
  #       background do
  #         within 'ul.pad-right' do
  #           find('.new-story').click
  #         end
  #       end

  #       scenario 'can create a new story' do
  #         expect(page).to have_text('Click to Add Story Title')
  #       end
  #     end
  #   end
  # end
end
