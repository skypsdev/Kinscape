# require 'spec_helper'

# feature 'Story deletion', :js do
#   let!(:user)    { create(:user) }
#   let!(:story_1) { create(:story, title: 'First story', user: user) }
#   let!(:story_2) { create(:story, title: 'Second story', user: user) }

#   shared_examples 'successful story draft deletion' do
#     scenario 'story deleted' do
#       within '.vue-dialog-buttons' do
#         find('.confirm-button').click
#       end

#       expect(page).to have_text 'First story has been deleted'

#       select 'Private Stories', from: 'family-filter'

#       within('.family-stories') do
#         expect(page).to have_no_text story_1.title
#       end
#     end
#   end

#   context 'from story page' do
#     background do
#       visit story_path(story_1, as: user)

#       click_on 'delete'
#     end

#     it_behaves_like 'successful story draft deletion'
#   end
# end
