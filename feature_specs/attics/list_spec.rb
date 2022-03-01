require 'spec_helper'

feature 'Viewing attics page', :js do
  let!(:user)         { create :user }
  let!(:family)       { create :family, users: [user] }
  let!(:friend)       { create :user, families: [family] }
  let!(:family_attic) { create :attic, user: user, family: family }

  scenario 'user sees 2 attics' do
    visit attics_path(as: friend)

    expect(page).to have_selector('.attic', count: 2)

    within 'li.attic:nth-child(1)' do
      expect(page).to have_text friend.private_attic.name
      expect(page).to have_selector(
        "a.cover[href='#{attic_path(friend.private_attic)}']"
      )
    end

    within 'li.attic:nth-child(2)' do
      expect(page).to have_text family.attic.name
      expect(page).to have_selector(
        "a.cover[href='#{attic_path(family.attic)}']"
      )
    end
  end

  # Temp. remove payment feature
  # context 'when the current user is guest' do
  #   background do
  #     create :subscription, user: user,
  #                           status: 'past_due',
  #                           trial_end: 10.days.ago

  #     visit attics_path(as: user)
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
  # end

  # context 'when the current user is trialing' do
  #   before do
  #     create :subscription, user: user,
  #                           status: 'trialing',
  #                           trial_end: Time.now + 10.days

  #     visit attics_path(as: user)
  #   end

  #   scenario 'can see trial button' do
  #     within 'ul.pad-right' do
  #       expect(page).to have_link \
  #         t(
  #           'subscriptions.upgrade_with_trial_days',
  #           day: user.subscription.trial_days
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
  #         within '.request-story-modal' do
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
