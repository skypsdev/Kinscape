# require 'spec_helper'

# feature 'Story editing', :js do
#   include StoriesPageHelpers

#   let(:family)  { create :family }
#   let(:user)    { create :user, families: [family] }
#   let(:section) { build :text_section }

#   let(:story) do
#     create :story, user: user,
#                    publications: publications,
#                    sections: [section]
#   end

#   let(:publications) { [] }
#   let(:story_attributes) do
#     {
#       title: 'Edited title',
#       description: 'Edited location',
#       start_year: '2001',
#       start_month: 'October',
#       start_day: '5',
#       end_year: '2001',
#       end_month: 'December',
#       end_day: '10',
#       is_range: true,
#       cover_image: {
#         url: 'http://placehold.it/edited.png'
#       }
#     }
#   end

#   background do
#     stub_mandrill
#     stub_request(:post, 'http://placehold.it/edited.png/convert?height=250'\
#                         '&key=fake_filepicker_api_key&rotate=exif'\
#                         '&storePath=/cover_images/small/&width=250')
#       .to_return(status: 200, body: '{}', headers: {})
#     stub_request(:post, 'http://placehold.it/edited.png/convert?height=500'\
#                         '&key=fake_filepicker_api_key&rotate=exif'\
#                         '&storePath=/cover_images/medium/&width=500')
#       .to_return(status: 200, body: '{}', headers: {})
#     stub_request(:post, 'http://placehold.it/edited.png/convert?height=900&'\
#                         'key=fake_filepicker_api_key&rotate=exif'\
#                         '&storePath=/cover_images/large/&width=900')
#       .to_return(status: 200, body: '{}', headers: {})
#     visit edit_story_path(story, as: user)
#   end

#   it 'shows author name' do
#     within 'article.story-title' do
#       expect(page).to have_css '.author'
#       expect(page).to have_text user.name
#     end
#   end

#   scenario 'edit mode has .edit-content-wrapper used for scrolling to top' do
#     expect(page).to have_css '.edit-content-wrapper'
#   end

#   context 'published' do
#     before do
#       build(:publication, family: family, story: story)
#     end

#     scenario 'click Done Editing when no changes made' do
#       click_on 'Done Editing'

#       within 'section.story-cover' do
#         expect(page).to have_text story.title
#       end

#       expect(page).to have_current_path(story_path(story))
#     end
#   end

#   context 'private' do
#     scenario 'private story should be read after editing' do
#       fill_in_story_form story_attributes

#       expect_saved_status

#       click_on 'Storyscape'

#       select 'Private Stories', from: 'family-filter'

#       within 'ul.stories li.story:nth-child(1)' do
#         expect(page).to have_text "Edited title\nEdited location"
#         expect(page).to have_no_text 'Unread'
#       end
#     end
#   end
# end
