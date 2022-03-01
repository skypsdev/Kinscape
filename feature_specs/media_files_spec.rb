require 'spec_helper'

feature 'MediaFiles', :js do
  include StoriesPageHelpers

  xscenario 'remove media file from section' do
    media_file_1 = create(:image)
    media_file_2 = create(:image)

    attachment_1 = build(
      :attachment,
      position: 1,
      media_file: media_file_1
    )

    attachment_2 = build(
      :attachment,
      position: 2,
      media_file: media_file_2
    )

    section = create(:section, attachments: [attachment_1, attachment_2])

    media_file_2.converted_urls['medium'] = 'http://placehold.it/60x'
    media_file_2.save!

    visit edit_story_path(section.story, rich: false, as: section.user)

    expect(page).to have_css('.photoset .photo', count: 2)

    find('.photoset .photo:nth-child(2)').hover

    click_with_confirm 'Remove Image'

    expect(page).to have_css('.photoset .photo', count: 1)

    visit story_path(section.story)

    expect(page).to have_converted_image?(media_file_1, 'medium')
    expect(page).not_to have_converted_image?(media_file_2, 'medium')
  end

  xscenario 'upload additional file to section' do
    new_file_url_1 = dummy_images.first[:url]
    new_file_url_2 = dummy_images.last[:url]

    stub_image_convert(dummy_images.first[:url])
    stub_image_convert(dummy_images.last[:url])
    stub_s3_requests

    media_file = create(:image)

    section = create(:section, media_files: [media_file])

    visit "/stories/#{section.story.id}/edit"
    add_file_to_section(url: new_file_url_1, key: dummy_images.first[:key])

    expect_saved_status

    visit "/stories/#{section.story.id}"

    expect(page).to have_converted_image?(media_file, 'medium')

    visit "/stories/#{section.story.id}/edit"
    add_file_to_section(url: new_file_url_2, key: dummy_images.last[:key])

    expect_saved_status
    expect(page).to have_text 'ADD IMAGES TO THIS SET'

    visit "/stories/#{section.story.id}"

    expect(page).to have_css('.photoset .photo', count: 3)
  end

  xscenario 'view images' do
    media_file = create(:image, url: 'http://placehold.it/30x')
    section = create(:section, media_files: [media_file])

    visit "/stories/#{section.story.id}"
    find('.photoset img').click

    expect(page).to \
      have_css(".image-wrapper img[src^='#{S3Config.cloudfront_endpoint}']")
  end

  xscenario 'cannot upload more than the limit' do
    new_file_url = 'http://example.com/new.mp4'
    media_files = Array.new(8) { create(:image, filename: 'test.mp4') }
    section = create(:section, media_type: 'video', media_files: media_files)

    visit "/stories/#{section.story.id}/edit"
    add_file_to_section(url: new_file_url, key: new_file_url.split('/').pop)

    expect(page).to \
      have_text(I18n.t('errors.attributes.media_files.too_long', maximum: 8))

    expect(section.media_files.size).to eq(8)
  end

  scenario 'can not see upload file button if set has 8 images' do
    media_files = create_list(:image, 8)
    section = create(:section, media_type: 'image', media_files: media_files)

    visit "/stories/#{section.story.id}/edit"

    expect(page).to have_no_text 'ADD IMAGES TO THIS SET'
  end

  private

  def stub_s3_requests
    stub_request(:put, dummy_images.first[:s3_request])
    stub_request(:put, dummy_images.last[:s3_request])
  end
end
