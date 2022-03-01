require 'spec_helper'

feature 'Comment creation', :js do
  include CommentsPageHelpers

  let!(:family) { create :family }

  let!(:user) do
    create :user, families: [family], first_name: 'John', last_name: 'Snow'
  end

  let!(:story)   { create :story, user: user, families: [family] }
  let!(:section) { create :section, story: story }

  background do
    visit story_path(story, as: user)
  end

  shared_examples 'added comment' do |position:, text:|
    scenario 'adds single comment' do
      within ".comments-wrapper li.comment:nth-child(#{position})" do
        expect(page).to have_text text
        expect(page).to have_text 'John Snow'
        expect(page).to have_text Time.zone.today.to_formatted_s(:long_ordinal)
        expect(page).to have_link 'Remove'
      end
    end
  end

  context 'for story' do
    background do
      open_story_comments_modal

      within '.story-comments-container' do
        add_comment 'First comment message'
      end
    end

    it_behaves_like 'added comment', position: 1, text: 'First comment message'
  end

  context 'multiple comments for story' do
    background do
      open_story_comments_modal

      within '.story-comments-container' do
        add_comment 'First comment message'
        add_comment 'Second comment message'
        remove_comment position: 1
        add_comment 'Third comment message'
      end
    end

    scenario 'removed comment does not appeare after adding new one' do
      within 'ul.comments' do
        expect(page).to have_no_text 'Second comment message'
      end
    end

    it_behaves_like 'added comment', position: 1, text: 'Third comment message'
    it_behaves_like 'added comment', position: 2, text: 'First comment message'
  end
end
