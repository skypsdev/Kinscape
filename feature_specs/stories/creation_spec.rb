# # frozen_string_literal: true

# require 'spec_helper'

# feature 'Stories creation', :js do
#   include StoriesPageHelpers

#   let(:story_attributes) do
#     {
#       title: 'Cool story',
#       description: 'Bay area',
#       start_year: '2001',
#       start_month: 'October',
#       start_day: '5',
#       end_year: '2001',
#       end_month: 'December',
#       end_day: '10',
#       is_range: true,
#       cover_image: {
#         url: 'http://placehold.it/story.png'
#       }
#     }
#   end

#   background do
#     user = create :user

#     visit root_path(as: user)
#     dismiss_cookieconsent

#     find(:css, '.new-story').click
#   end

#   scenario 'create new story' do
#     fill_in_story_form story_attributes
#     sleep(1)
#     expect_saved_status

#     click_on 'Done Editing'

#     within 'section.story-cover' do
#       expect(page).to have_text 'Cool story'
#       # expect(page).to have_text 'Bay area'
#       expect(page).to have_text 'October 5th - December 10th, 2001'
#     end
#   end

#   scenario 'create a new story with a section' do
#     expect(page).to have_css('trix-editor', text: '')

#     fill_in_story_form story_attributes

#     within '.add-content-bottom' do
#       find(:css, '.add-chapter-btn').click
#     end

#     expect(page).to have_css('trix-editor', count: 2)
#     editor = all('trix-editor').last

#     fill_in 'sectionTitle', with: 'My Section title', match: :first

#     editor.set 'New section content'

#     expect_saved_status

#     click_on 'Done Editing'

#     expect(page).to have_current_path(%r/stories\/[0-9]+$/)

#     expect(page).to have_selector('h1', text: 'My Section title')
#   end

#   # scenario 'private story should be read after creation' do
#   #   expect(page).to have_css 'h1.story-title', text: 'Click to Add Story Title'

#   #   click_on 'Storyscape'

#   #   select 'Private Stories', from: 'family-filter'

#   #   within '.family-stories' do
#   #     expect(page).to have_text 'Click to Add Story Title'
#   #     expect(page).to have_no_text 'Unread'
#   #   end
#   # end
# end
