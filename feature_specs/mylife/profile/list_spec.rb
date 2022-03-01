require 'spec_helper'

# feature 'Public Profile', :js do
#   let!(:connector) do
#     create :user, first_name: 'Mark',
#                   last_name: 'Smith',
#                   email: 'mark.smith@email.com'
#   end

#   let!(:family_member) do
#     create :user, first_name: 'Jake',
#                   last_name: 'Smith',
#                   email: 'jake.smith@email.com'
#   end

#   let!(:ward) do
#     create :user, first_name: 'Tarzan',
#                   last_name: 'Pet',
#                   caretaker_id: connector.id
#   end

#   let!(:family) do
#     create :family, name: 'Smith\'s',
#                     users: [connector, ward],
#                     connector: connector
#   end

#   let!(:kinship) do
#     create :kinship, user: family_member,
#                      family: family,
#                      rich_profile: '<h1>Shared title</h1><p>Shared body</p>'
#   end

#   context 'viewing user profile' do
#     background do
#       visit "/families/#{family.id}/kinships?as=#{connector.id}"

#       click_on 'Jake Smith'
#     end

#     scenario 'show user profile' do
#       expect(page).to have_text 'Shared title'
#       expect(page).to have_text 'Shared body'
#     end

#     scenario 'user can navigate to family page' do
#       click_on 'Back'

#       expect(page).to have_current_path("/families/#{family.id}/kinships")
#     end

#     scenario 'click on "Send a Message" opens proper popup' do
#       within '#profile_sidebar header.user' do
#         click_on 'Send a Message'
#       end

#       within '.request-story-modal' do
#         expect(page).to have_css('h2', text: 'Send A Message')
#       end
#     end
#   end

#   context 'empty state' do
#     let!(:kinship) do
#       create :kinship, user: family_member,
#                        family: family
#     end

#     background do
#       visit "/families/#{family.id}/kinships?as=#{connector.id}"

#       click_on 'Jake Smith'
#     end

#     scenario 'show empty state message' do
#       expect(page).to have_text 'This Family Member has no shared information'
#     end
#   end

#   context 'user\'s information sidebar' do
#     context 'when viewing as a family connector' do
#       background do
#         visit "/families/#{family.id}/kinships?as=#{connector.id}"
#       end

#       scenario 'viewing own information' do
#         click_on 'Mark Smith'

#         within '#profile_sidebar' do
#           expect(page).to have_css '#user_name', text: 'Mark Smith'
#           expect(page).to \
#             have_no_link 'Edit Profile', exact_text: false
#           expect(page).to have_no_link 'Send a Message'
#         end
#       end

#       scenario 'viewing other family member info' do
#         click_on 'Jake Smith'

#         within '#profile_sidebar' do
#           expect(page).to have_css '#user_name', text: 'Jake Smith'
#           expect(page).to \
#             have_no_link 'Edit Profile', exact_text: false
#           expect(page).to have_link 'Send a Message'
#         end
#       end

#       scenario 'viewing ward\'s info' do
#         click_on 'Tarzan Pet'

#         within '#profile_sidebar' do
#           expect(page).to have_css '#user_name', text: 'Tarzan Pet'
#           expect(page).to \
#             have_no_link 'Edit Profile', exact_text: false
#           expect(page).to have_no_link 'Send a Message'
#           expect(page).to have_no_css '#user_email'
#         end
#       end
#     end

#     context 'when viewing as a family member' do
#       background do
#         visit "/families/#{family.id}/kinships?as=#{family_member.id}"
#       end

#       scenario 'viewing own information' do
#         click_on 'Jake Smith'

#         within '#profile_sidebar' do
#           expect(page).to have_css '#user_name', text: 'Jake Smith'
#           expect(page).to \
#             have_no_link 'Edit Profile', exact_text: false
#           expect(page).to have_no_link 'Send a Message'
#         end
#       end

#       scenario 'viewing other family member info' do
#         click_on 'Mark Smith'

#         within '#profile_sidebar' do
#           expect(page).to have_css '#user_name', text: 'Mark Smith'
#           expect(page).to \
#             have_no_link 'Edit Profile', exact_text: false
#           expect(page).to have_link 'Send a Message'
#         end
#       end

#       scenario 'viewing ward\'s info' do
#         click_on 'Tarzan Pet'

#         within '#profile_sidebar' do
#           expect(page).to have_css '#user_name', text: 'Tarzan Pet'
#           expect(page).to \
#             have_no_link 'Edit Profile', exact_text: false
#           expect(page).to have_no_link 'Send a Message'
#           expect(page).to have_no_css '#user_email'
#         end
#       end
#     end
#   end

#   context 'subnavigation for a connector' do
#     background do
#       visit "/families/#{family.id}/kinships?as=#{connector.id}"
#     end

#     scenario 'viewing own profile' do
#       click_on 'Mark Smith'

#       kinship = family.kinship_for(connector)

#       within find('.my-life-submenu') do
#         expect(page).to \
#           have_link 'Profile', href: kinship_mylife_profile_path(kinship)
#         expect(page).to \
#           have_link 'Stories', href: stories_path(user: connector.id)
#       end
#     end

#     scenario 'viewing other family member profile' do
#       click_on 'Jake Smith'

#       within '#my-life-submenu' do
#         expect(page).to \
#           have_link 'Profile', href: kinship_mylife_profile_path(kinship)
#         expect(page).to \
#           have_link 'Stories'
#       end
#     end

#     scenario 'viewing profile of a ward' do
#       click_on 'Tarzan Pet'

#       within '#my-life-submenu' do
#         expect(page).to have_no_link 'Stories'
#       end
#     end
#   end

#   context 'subnavigation for a family member' do
#     background do
#       visit "/families/#{family.id}/kinships?as=#{family_member.id}"
#     end

#     scenario 'viewing own profile' do
#       click_on 'Jake Smith'

#       within '.my-life-submenu' do
#         expect(page).to \
#           have_link 'Profile', href: kinship_mylife_profile_path(kinship)
#         expect(page).to \
#           have_link 'Stories', href: stories_path(user: family_member.id)
#       end
#     end

#     scenario 'viewing other family member profile' do
#       click_on 'Mark Smith'

#       kinship = family.kinship_for(connector)

#       within '.my-life-submenu' do
#         expect(page).to \
#           have_link 'Profile', href: kinship_mylife_profile_path(kinship)
#         expect(page).to \
#           have_link 'Stories'
#         expect(page).to have_no_link 'Identity'
#       end
#     end

#     scenario 'viewing profile of a ward' do
#       click_on 'Tarzan Pet'

#       within '.my-life-submenu' do
#         expect(page).to have_no_link 'Stories'
#       end
#     end
#   end

#   # Temp. remove payment feature
#   # context 'when the current user is guest' do
#   #   background do
#   #     create :subscription, user: connector,
#   #                           status: 'past_due',
#   #                           trial_end: 10.days.ago

#   #     visit "/families/#{family.id}/kinships?as=#{connector.id}"
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
#   #     create :subscription, user: connector,
#   #                           status: 'trialing',
#   #                           trial_end: Time.now + 10.days

#   #     visit "/families/#{family.id}/kinships"
#   #   end

#   #   scenario 'can see trial button' do
#   #     within 'ul.pad-right' do
#   #       expect(page).to have_link \
#   #         t(
#   #           'subscriptions.upgrade_with_trial_days',
#   #           day: connector.subscription.trial_days
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
#   #         within '.request-story-modal' do
#   #           expect(page).to have_text 'Send A Message To Members'
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

#   #       scenario 'can create a new story' do
#   #         expect(page).to have_text('Click to Add Story Title')
#   #       end
#   #     end
#   #   end
#   # end
# end
