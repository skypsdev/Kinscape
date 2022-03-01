require 'spec_helper'

feature 'Reviewing Attic', :js do
  include AtticsPageHelpers

  let(:user)                { create :user }
  let(:image_attachment)    { create :attachment }
  let(:audio_attachment)    { create :attachment, :audio }
  let(:document_attachment) { create :attachment, :document }
  let(:video_attachment)    { create :attachment, :video }
  let(:private_attachments) do
    [
      video_attachment,
      audio_attachment,
      image_attachment,
      document_attachment
    ]
  end

  background do
    user.private_attic.attachments << private_attachments
    visit attic_path user.private_attic, as: user
  end

  scenario 'user sees a document' do
    within('#attic li:nth-child(1)') do
      filename = document_attachment.media_file.filename
      expect(page).to have_css('.file-name', text: filename)
    end
  end

  scenario 'user previews an image' do
    click_on_file(position: 2)
    attachment_modal_preview_present(image_attachment)
  end

  scenario 'user previews an audio file' do
    click_on_file(position: 3)
    attachment_modal_preview_present(audio_attachment)
  end

  scenario 'user previews a video file' do
    click_on_file(position: 4)
    attachment_modal_preview_present(video_attachment)
  end
end
