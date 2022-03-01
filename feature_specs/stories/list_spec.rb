# # frozen_string_literal: true

# require 'spec_helper'

# feature 'Stories list', :js do
#   let!(:family_1)    { create :family, name: 'Purrkins' }
#   let!(:family_2)    { create :family, name: 'Smiths' }
#   let!(:user)        { create(:user, families: [family_1, family_2]) }
#   let!(:contributor) { create(:user, families: [family_1, family_2]) }

#   let!(:story_1) do
#     create :story, user: user, title: 'Story One', families: [family_1]
#   end

#   let!(:story_2) do
#     create :story, user: user, title: 'Story Two', families: [family_2]
#   end

#   before do
#     create :section, author: contributor, story: story_1
#   end

#   shared_examples 'story tile' do |edit_title:|
#     scenario 'view stories' do
#       within '.stories .story:nth-child(1)' do
#         expect(page).to have_text 'Story One'
#         expect(page).to have_link('open', href: story_path(story_1))
#         expect(page).to have_link(edit_title, href: edit_story_path(story_1))
#         expect(page).to have_link('0 comments | 0',
#                                   href: story_path(story_1) + '/comments')
#       end

#       expect(page).not_to have_text 'Story Two'
#     end

#     scenario 'story details on hover' do
#       find('.stories .story:nth-child(1)').hover

#       within '.stories .story:nth-child(1)' do
#         expect(page).to have_text 'Story One'
#         expect(page).to have_text '1 collaborator'
#         expect(page).to have_text 'Shared withPurrkins'
#         expect(page).to have_text '0 comments | 0'
#       end
#     end
#   end

#   context 'own stories' do
#     before do
#       visit stories_path(as: user)
#     end

#     it_behaves_like 'story tile', edit_title: 'edit'
#   end

#   context 'contributed stories' do
#     before do
#       visit stories_path(as: contributor)
#     end

#     it_behaves_like 'story tile', edit_title: 'collaborate'
#   end

#   # Temp. remove payment feature
#   # context 'when the current user is guest' do
#   #   before do
#   #     create :subscription, user: user,
#   #                           status: 'past_due',
#   #                           trial_end: 10.days.ago

#   #     visit stories_path(as: user)
#   #   end

#   #   scenario 'can see guest button' do
#   #     within 'ul.pad-right' do
#   #       expect(page).to have_link 'Guest'
#   #     end
#   #   end

#   #   context 'message button' do
#   #     scenario 'can see message button' do
#   #       within 'ul.pad-right' do
#   #         expect(page).to have_link 'Message'
#   #       end
#   #     end

#   #     context 'when click the message button' do
#   #       background do
#   #         within 'ul.pad-right' do
#   #           click_on 'Message'
#   #         end
#   #       end

#   #       scenario 'see the account upgrade modal' do
#   #         within all('.confirmation-dialog')[0] do
#   #           expect(page).to have_text t('account.upgrade_account_confirm.title')
#   #         end
#   #       end
#   #     end
#   #   end

#   #   context 'start story button' do
#   #     scenario 'can see start story button' do
#   #       within 'ul.pad-right' do
#   #         expect(page).to have_text 'Start a Story'
#   #       end
#   #     end

#   #     context 'when click the start story button' do
#   #       background do
#   #         within 'ul.pad-right' do
#   #           find('.new-story').click
#   #         end
#   #       end

#   #       scenario 'see the account upgrade modal' do
#   #         within all('.confirmation-dialog')[0] do
#   #           expect(page).to have_text t('account.upgrade_account_confirm.title')
#   #         end
#   #       end
#   #     end
#   #   end
#   # end

#   # context 'when the current user is trialing' do
#   #   before do
#   #     create :subscription, user: user,
#   #                           status: 'trialing',
#   #                           trial_end: Time.now + 10.days

#   #     visit stories_path(as: user)
#   #   end

#   #   scenario 'can see trial button' do
#   #     within 'ul.pad-right' do
#   #       expect(page).to have_link \
#   #         t(
#   #           'subscriptions.upgrade_with_trial_days',
#   #           day: user.subscription.trial_days
#   #         )
#   #     end
#   #   end

#   #   context 'message button' do
#   #     scenario 'can see message button' do
#   #       within 'ul.pad-right' do
#   #         expect(page).to have_link 'Message'
#   #       end
#   #     end

#   #     context 'when click the message button' do
#   #       background do
#   #         within 'ul.pad-right' do
#   #           click_on 'Message'
#   #         end
#   #       end

#   #       scenario 'see the message modal' do
#   #         expect(page).to have_text 'Send A Message To Members'
#   #       end
#   #     end
#   #   end

#   #   context 'start story button' do
#   #     scenario 'can see start story button' do
#   #       within 'ul.pad-right' do
#   #         expect(page).to have_text 'Start a Story'
#   #       end
#   #     end

#   #     context 'when click the start story button' do
#   #       background do
#   #         within 'ul.pad-right' do
#   #           find('.new-story').click
#   #         end
#   #       end

#   #       scenario 'can create a new story' do
#   #         expect(page).to have_text('Click to Add Story Title')
#   #       end
#   #     end
#   #   end
#   # end
# end
