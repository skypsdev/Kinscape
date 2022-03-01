# frozen_string_literal: true

require 'spec_helper'

xfeature 'Tags', :js do
  include StoriesPageHelpers

  scenario 'add first tag for published story' do
    family = create :family
    story  = create :story, families: [family]

    Publication.create! story: story, family: family

    visit edit_story_path story, as: story.user

    expect(page).to have_text story.title
    expect(page).to have_text '0 Categories'

    story_tag_panel.click

    expect(page).to have_selector(
      "input[placeholder='Pick Category or Start New']"
    )

    within '.multiselect__content' do
      expect(page).to have_text('birthday family graduation life sport wedding',
                                normalize_ws: true)
    end

    fill_story_tag 'birthday'

    expect_saved_status

    expect(story_tag_panel).to have_text 'birthday'
    find('body').click
    expect(page).to have_text '1 Categories'
  end

  scenario 'add additional tag for published story' do
    family = create :family
    story  = create :story, families: [family], tags: ['birthday']

    Publication.create! story: story, family: family

    visit edit_story_path story, as: story.user

    expect(page).to have_text '1 Categories'

    story_tag_panel.click

    expect(page).to have_selector(
      "input[placeholder='Pick Category or Start New']"
    )

    story_tag_panel.click

    within '.multiselect__content' do
      expect(page).to have_text('family graduation life sport wedding',
                                normalize_ws: true)
    end

    fill_story_tag 'graduation'

    expect_saved_status
    expect(story_tag_panel).to have_text('birthday graduation',
                                         normalize_ws: true)
    find('body').click
    expect(page).to have_text '2 Categories'
  end
end
