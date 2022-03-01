require 'spec_helper'

describe StoryAssetMailer do
  subject(:mail) { described_class.new(recipient: nil, story: story) }

  let(:story) { create(:story) }

  context 'when the story has media files' do
    pending 'is true' do
      expect(story.cover_image).to be_present
      expect(mail).to be_should_send
      expect(mail.media_files_for_story).to match_array [story.cover_image]
    end
  end

  context 'when the story has no media files' do
    pending 'is false' do
      allow(story).to receive(:cover_image).and_return(nil)
      expect(mail).not_to be_should_send
      expect(mail.media_files_for_story).to match_array []
    end
  end
end
