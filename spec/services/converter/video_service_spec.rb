require 'spec_helper'

describe Converter::VideoService do
  subject(:result) { described_class.call(attachment: attachment) }

  let(:user) { create :user }
  let(:family) { create :family, users: [user] }
  let(:video_blob) { create_file_blob(filename: 'mpeg4.wmv') }

  context 'with Action Text Attachment' do
    let(:action_text_attachment) do
      ActionText::Attachment
        .from_attachable(video_blob, url: video_blob.signed_id, href: video_blob.signed_id)
    end
    let(:section) { create :section, author: user, rich_body: ActionText::Content.new(action_text_attachment) }
    let(:attachment) { ActiveStorage::Attachment.find_by(record: section.rich_body) }

    it do
      expect(FFMPEG::Movie.new('spec/fixtures/files/mpeg4.wmv').video_codec).to eq('msmpeg4v3')
      expect { result }.to have_enqueued_job(ActiveStorage::PurgeJob)
        .and(change { section.rich_body.reload.body.to_html })
      expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      new_attachment = ActiveStorage::Attachment.find_by(record: section.rich_body)
      new_attachment.blob.open(tmpdir: '/tmp') do |file|
        expect(FFMPEG::Movie.new(file.path).video_codec).to eq('h264')
      end
    end
  end

  context 'with non Action Text Attachment' do
    let(:vault) { user.vault }
    let!(:attachment) { create :active_storage_attachment, blob: video_blob, record: vault }

    it do
      expect(FFMPEG::Movie.new('spec/fixtures/files/mpeg4.wmv').video_codec).to eq('msmpeg4v3')
      expect { result }.to have_enqueued_job(ActiveStorage::PurgeJob)
        .and change(attachment, :blob_id)
      attachment.blob.open(tmpdir: '/tmp') do |file|
        expect(FFMPEG::Movie.new(file.path).video_codec).to eq('h264')
      end
    end
  end
end
