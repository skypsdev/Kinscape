# require 'spec_helper'

# feature 'Story viewing', :js do
#   include StoriesPageHelpers

#   let!(:family) { create :family }
#   let!(:user)   { create :user, families: [family] }

#   let!(:story) do
#     create(
#       :story,
#       title: 'My Summer Adventures',
#       start_year: '2001',
#       start_month: 'February',
#       start_day: '5',
#       end_year: '2001',
#       end_month: 'December',
#       end_day: '6',
#       is_range: true,
#       description: 'Madagascar',
#       user: user,
#       tags: %w(life adventures sea lemur)
#     )
#   end

#   context 'own story' do
#     background do
#       visit story_path(story, as: user)
#     end

#     scenario 'view mode has .story-container id used for scrolling to top' do
#       expect(page).to have_css '.story-container'
#     end

#     scenario 'view story content' do
#       within 'article.story-title' do
#         expect(story_cover_image.gsub!(/\A"|"\Z/, '')).to \
#           match(/^#{story.cover_image.cdn_url(format: "medium")}/)

#         expect(page).to have_text 'My Summer Adventures'
#         expect(page).to have_text 'Madagascar'
#         expect(page).to have_text 'February 5th - December 6th, 2001'
#         expect(page).to have_text 'life, adventures, sea, lemur'
#       end
#     end

#     scenario 'view action sub navigation on large screen' do
#       within '.submenu' do
#         %w(edit copy share print delete comment 0).each do |text|
#           expect(page).to have_text text
#         end

#         expect(page).to have_link 'edit', href: edit_story_path(story)
#         expect(page).to have_link 'copy'
#         expect(page).to have_link 'share'
#         expect(page).to have_link 'print'
#         expect(page).to have_link 'comment'
#         expect(page).to have_link 'delete'
#         expect(page).to have_selector 'a[title="Like"]', text: '0'
#       end
#     end

#     scenario 'view action sub navigation on medium screen', screen: :medium do
#       within '.submenu' do
#         %w(edit copy share delete 0).each do |text|
#           expect(page).to have_no_text text
#         end

#         expect(page).to have_link 'edit', href: edit_story_path(story)
#         expect(page).to have_link 'copy'
#         expect(page).to have_link 'share'
#         expect(page).to have_link 'delete'
#         expect(page).to have_link 'comment'
#       end
#     end

#     scenario 'view action sub navigation on small screen', screen: :small do
#       within '.submenu' do
#         %w(edit delete).each do |text|
#           expect(page).to have_no_text text
#         end

#         expect(page).to have_link 'edit', href: edit_story_path(story)
#         expect(page).to have_link 'delete'
#       end
#     end
#   end

#   context 'own time capsule story' do
#     background do
#       family.publications.create story: story, publish_on: 1.year.from_now
#       visit story_path(story, as: user)
#     end

#     scenario 'view action sub navigation' do
#       within '.submenu' do
#         expect(page).to have_link 'time capsule'
#         expect(page).to have_no_link 'share'
#       end
#     end
#   end

#   context 'own shared story' do
#     background do
#       family.publications.create story: story
#       visit story_path(story, as: user)
#     end

#     scenario 'view action sub navigation' do
#       within '.submenu' do
#         expect(page).to have_link 'edit', href: edit_story_path(story)
#         expect(page).to have_link 'copy'
#         expect(page).to have_link 'print'
#         expect(page).to have_link 'comment'
#         expect(page).to have_link 'unshare'
#         expect(page).to have_selector 'a[title="Like"]', text: '0'

#         expect(page).to have_no_link 'delete'
#       end
#     end
#   end

#   context 'shared story' do
#     let!(:contributor) { create(:user, families: [family]) }

#     background do
#       family.publications.create story: story
#     end

#     scenario 'view action sub navigation' do
#       visit story_path(story, as: contributor)

#       within '.submenu' do
#         expect(page).to have_link 'collaborate', href: edit_story_path(story)
#         expect(page).to have_link 'print'
#         expect(page).to have_link 'comment'
#         expect(page).to have_selector 'a[title="Like"]', text: '0'

#         expect(page).to have_no_link 'delete'
#         expect(page).to have_no_link 'copy'
#       end
#     end

#     context 'when the contributor is guest' do
#       before do
#         create :subscription, user: contributor,
#                               status: 'past_due',
#                               trial_end: 10.days.ago
#       end

#       scenario 'can not see the collaborate and comment buttons' do
#         visit story_path(story, as: contributor)

#         expect(page).to have_no_link 'collaborate'
#         expect(page).to have_no_link 'comment'
#       end

#       context 'when the story is in a group plan family' do
#         before do
#           subscription = create :subscription,
#                                 billing_plan_data: { id: 'group' }
#           family.connector = subscription.user
#           family.save
#         end

#         scenario 'can see the collaborate and comment buttons' do
#           visit story_path(story, as: contributor)

#           expect(page).to have_link 'collaborate'
#           expect(page).to have_link 'comment'
#         end
#       end
#     end
#   end
# end
