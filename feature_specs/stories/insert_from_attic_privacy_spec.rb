# require 'spec_helper'

# feature 'Insert from attic privacy', :js do
#   include AtticsPageHelpers

#   let(:user)   { create :user }
#   let(:family) { create :family, users: [user], name: 'Smith' }

#   let!(:attic)   { create :attic, family: family, user: user }
#   let!(:section) { create :text_section, story: story }

#   background do
#     create :family, users: [user], name: 'Jake'

#     visit edit_story_path(story, as: user)

#     open_attic_modal
#   end

#   context 'shared story' do
#     let(:story) { create :story, user: user, families: [family] }

#     scenario 'sees own attic and attic of the family story\'s shared with' do
#       within '.attic-modal' do
#         expect(page).to have_text 'My Attic'
#         expect(page).to have_text 'Smith Family Attic'
#         expect(page).to_not have_text 'Jake Family Attic'
#       end
#     end
#   end

#   context 'private story' do
#     let(:story) { create :story, user: user }

#     scenario 'sees only own attic' do
#       within '.attic-modal' do
#         expect(page).to have_text 'My Attic'
#         expect(page).to_not have_text 'Smith Family Attic'
#         expect(page).to_not have_text 'Jake Family Attic'
#       end
#     end
#   end
# end
