# require 'spec_helper'

# feature 'Stories copying', :js do
#   let!(:family) { create(:family, name: 'Family One') }
#   let!(:user)    { create(:user, families: [family]) }
#   let!(:story) { create :story, title: 'First story', user: user }

#   background do
#     family.publications.create story: story, publish_on: 1.year.from_now
#   end

#   shared_examples 'successfully copied story' do
#     scenario 'story copied' do
#       expect(page).to have_css '.alert', text: 'story has been copied'
#       expect(page).to have_css 'h1.story-title', text: 'Copy First story'
#     end

#     scenario 'private story should be read' do
#       expect(page).to have_css 'h1.story-title', text: 'Copy First story'

#       click_on 'Storyscape'

#       expect(page).to have_current_path(stories_path)

#       select 'Private Stories', from: 'family-filter'

#       within 'ul.stories li.story:nth-child(1)' do
#         expect(page).to have_text 'Copy First story'
#         expect(page).to have_no_text 'Unread'
#       end
#     end
#   end

#   context 'from story page' do
#     background do
#       visit story_path(story, as: user)

#       click_on 'copy'
#     end

#     it_behaves_like 'successfully copied story'
#   end

#   context 'from stories list page' do
#     background do
#       visit stories_path(as: user)

#       within 'li.story:nth-child(1)' do
#         click_on 'copy'
#       end
#     end

#     it_behaves_like 'successfully copied story'
#   end
# end
