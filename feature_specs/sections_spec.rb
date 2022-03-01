require 'spec_helper'

feature 'Sections', :js do
  include StoriesPageHelpers

  let!(:story) { create :story }

  scenario 'insert a text section' do
    create :section, story: story

    visit edit_story_path(story, as: story.user)

    within '.edit-content-wrapper .section:nth-child(1)' do
      find('trix-editor').click.set('Some body text')
    end
    expect_saved_status

    visit story_path(story)

    expect(story_section(index: 1)).to have_text('Some body text')
  end

  scenario 'remove a section' do
    section = create(:section, media_type: 'image', body: 'Remove me')

    visit edit_story_path(section.story, as: section.user)

    within '.edit-content-wrapper .section:nth-child(1)' do
      find('a.remove-section').click
      find('button.btn-delete').click
    end

    expect(page).to have_no_css('input.caption')
    expect_saved_status

    visit story_path(section.story)

    expect(page).to have_no_text(section.body)
  end

  private

  def stub_s3_request
    stub_request(:put, dummy_images.first[:s3_request])
  end
end
