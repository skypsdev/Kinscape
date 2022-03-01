require 'spec_helper'

feature 'Comment deletion', :js do
  include CommentsPageHelpers

  let!(:family)  { create :family }
  let!(:user)    { create :user, families: [family] }
  let!(:story)   { create :story, user: user, families: [family] }

  context 'from story' do
    let!(:comment) do
      create :comment, commentable: story, user: user, body: 'My comment body'
    end

    background do
      visit story_path(story, as: user)
      open_story_comments_modal

      within '.story-comments-container' do
        remove_comment position: 1
      end
    end

    scenario 'removes comment' do
      within 'ul.comments' do
        expect(page).to have_no_text 'My comment body'
      end
    end
  end
end
