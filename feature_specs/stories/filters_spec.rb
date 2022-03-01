# require 'spec_helper'

# feature 'Stories filters', :js do
#   scenario 'show categories of published stories in select' do
#     user = create :user
#     family = create :family, users: [user]
#     story  = create :story, user: user, tags: %w(birthday party)

#     Publication.create! story: story, family: family

#     visit stories_path as: user

#     expect(page).to \
#       have_select :search_tag, options: [
#         ' Any category ', ' birthday ', ' party '
#       ]
#   end
# end
