# require 'spec_helper'

# feature 'Story collaborating', :js do
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
#     visit edit_story_path(story, as: collaborator)
#   end

#   scenario 'cannot edit story' do
#     within 'section.story-cover' do
#       expect(page).to have_css 'h1[contenteditable="false"]', text: 'Title'
#       expect(page).to have_css '#story_location[disabled="disabled"]'
#       expect(page).to have_css '#story-startYear[disabled="disabled"]'
#       expect(page).to have_css '#story-endYear[disabled="disabled"]'
#       expect(page).to have_css '.story-isRange[disabled="disabled"]'
#     end
#   end
# end
