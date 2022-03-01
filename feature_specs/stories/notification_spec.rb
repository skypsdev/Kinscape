# require 'spec_helper'

# feature 'Stories', :js do
#   include StoriesPageHelpers

#   let(:family) { create :family }
#   let!(:user)  { create :user, families: [family] }
#   let!(:story) { create :story, title: 'Story title', user: user }

#   context 'private story' do
#     scenario 'do not ask to send notification' do
#       visit edit_story_path(story, as: user)

#       fill_story_title 'Edited title'
#       expect_saved_status

#       click_on 'Done Editing'

#       expect(page).to have_current_path(story_path(story))
#     end
#   end

#   context 'shared story' do
#     background do
#       family.publications.create!(story: story)
#     end

#     scenario 'send notification' do
#       visit edit_story_path(story, as: user)

#       fill_story_title 'Edited title'
#       expect_saved_status

#       click_on 'Done Editing'

#       within '.story-update-modal' do
#         find('#notify-family__yes').click
#       end

#       expect(page).to \
#         have_content 'notification successfully sent to your Family Members!'
#       expect(family.publications.first.notified_at).not_to be_nil
#     end
#   end
# end
