# require 'spec_helper'

# feature 'Story publishing', :js do
#   shared_examples 'story successfully shared' do
#     scenario 'marked as shared' do
#       expect(page).to have_text 'Your story has been shared'

#       visit edit_story_path(story)

#       click_on 'Storyscape'

#       expect(page).to have_text(story.title)
#     end
#   end

#   context 'when families exist' do
#     let!(:family1) { create(:family, name: 'Family One') }
#     let!(:family2) { create(:family, name: 'Family Two') }
#     let!(:user)    { create(:user, families: [family1, family2]) }
#     let!(:story)   { create(:story, title: 'Some story', user: user) }

#     context 'from story page' do
#       background do
#         visit story_path(story, as: user)
#         click_on 'share'

#         within '.share-story-modal' do
#           select(family1.name, from: 'family-select')
#           find('.publish').click
#         end
#       end

#       it_behaves_like 'story successfully shared'
#     end
#   end
# end
