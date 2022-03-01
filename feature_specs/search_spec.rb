require 'spec_helper'

xfeature 'Search' do
  scenario 'for story using filters', js: true do
    family_1 = create(:family, name: 'Family One')
    family_2 = create(:family, name: 'Family Two')

    user_1 = create(:user, families: [family_1, family_2])
    user_2 = create(:user, families: [family_1])

    story_1 = create(:story, user: user_1, title: 'Once upon a time')
    story_2 = create(:story, user: user_2, title: 'Not found', tags: ['life'])
    story_3 = create(:story, user: user_2, title: 'Upon a hill')

    family_1.stories << [story_1, story_2, story_3]
    family_2.stories << [story_1]

    visit stories_path(as: user_1)
    fill_in t('stories.search'), with: 'upon'
    find('.search-wrapper button').click

    expect(page).to have_text(story_1.title)
    expect(page).to have_text(story_3.title)
    expect(page).to have_no_text(story_2.title)

    select(user_1.name, from: :search_user_id)

    expect(page).to have_text(story_1.title)
    expect(page).to have_no_text(story_3.title)
    expect(page).to have_no_text(story_2.title)

    select('life', from: :search_tag)

    expect(page).to have_text(story_2.title)
    expect(page).to have_no_text(story_1.title)
    expect(page).to have_no_text(story_3.title)

    select(family_2.name, from: :search_family_id)

    expect(page).to have_text(story_1.title)
    expect(page).to have_no_text(story_2.title)
    expect(page).to have_no_text(story_3.title)
  end
end
