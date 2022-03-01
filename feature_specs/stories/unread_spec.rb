# require 'spec_helper'

# feature 'Story unread', :js do
#   include StoriesPageHelpers

#   let(:author)       { create :user }
#   let(:collaborator) { create :user }
#   let(:family) do
#     create :family, connector: author, users: [author, collaborator]
#   end

#   let(:story) { create :story, story_attributes }

#   let!(:section) { create :text_section, story: story }

#   let(:story_attributes) do
#     {
#       title: 'Title',
#       description: 'Location',
#       start_year: '2001',
#       start_month: 'October',
#       start_day: '5',
#       end_year: '2001',
#       end_month: 'December',
#       end_day: '10',
#       is_range: true,
#       user: author,
#       families: [family]
#     }
#   end

#   background do
#     story.mark_as_read! for: author
#   end

#   context 'after author creates a new story' do
#     scenario 'author doesn\'t see the unread tag on the story' do
#       visit root_path(as: author)

#       expect(page).to have_no_text 'Unread'
#     end

#     scenario 'collaborator sees the unread tag on the story' do
#       visit root_path(as: collaborator)

#       expect(page).to have_text 'Unread'
#     end
#   end

#   context 'after author updates the story' do
#     before do
#       visit story_path(story, as: collaborator)

#       visit edit_story_path(story, as: author)

#       fill_story_title 'Cool'

#       expect_saved_status

#       click_on 'Done Editing'
#     end

#     scenario 'author doesn\'t see the unread tag on the story' do
#       visit root_path(as: author)

#       expect(page).to have_no_text 'Unread'
#     end

#     scenario 'collaborator sees the unread tag on the story' do
#       visit root_path(as: collaborator)

#       expect(page).to have_text 'Unread'
#     end
#   end

#   context 'after author updates the story cover image' do
#     before do
#       visit story_path(story, as: collaborator)

#       story.cover_image.update(url: 'http://placehold.it/edited.png')
#     end

#     scenario 'collaborator sees the unread tag on the story' do
#       visit root_path(as: collaborator)

#       expect(page).to have_text 'Unread'
#     end
#   end

#   context 'after author updates sections of the story' do
#     before do
#       story.mark_as_read! for: collaborator

#       visit edit_story_path(story, as: author)

#       add_section 'Some text'

#       expect_saved_status

#       click_on 'Done Editing'
#     end

#     scenario 'author doesn\'t see the unread tag on the story' do
#       visit root_path(as: author)

#       expect(page).to have_no_text 'Unread'
#     end

#     scenario 'collaborator sees the unread tag on the story' do
#       visit root_path(as: collaborator)

#       expect(page).to have_text 'Unread'
#     end
#   end

#   context 'after collaborator opens the story' do
#     before do
#       visit story_path(story, as: collaborator)
#     end

#     scenario 'collaborator doesn\'t see the unread tag on the story' do
#       visit root_path(as: collaborator)

#       expect(page).to have_no_text 'Unread'
#     end
#   end
# end
