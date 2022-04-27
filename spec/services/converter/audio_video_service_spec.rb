require 'spec_helper'

describe Converter::AudioVideoService do
  subject(:result) { described_class.call(attachment_id: attachment.id) }

  let(:user) { create :user }
  let(:family) { create :family, users: [user] }
  let(:blob) { create_file_blob(filename: 'test_audio.oga', content_type: 'audio/mpeg') }

  context 'with Action Text Attachment' do
    let(:action_text_attachment) do
      ActionText::Attachment
        .from_attachable(blob, url: blob.signed_id, href: blob.signed_id)
    end
    let(:section) { create :section, author: user, rich_body: ActionText::Content.new(action_text_attachment) }
    let(:attachment) { ActiveStorage::Attachment.find_by(record: section.rich_body) }

    it do
      expect(FFMPEG::Movie.new('spec/fixtures/files/test_audio.oga').audio_codec).to eq('opus')
      expect { result }.to have_enqueued_job(ActiveStorage::PurgeJob)
        .and(change { section.rich_body.reload.body.to_html })
      expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      new_attachment = ActiveStorage::Attachment.find_by(record: section.rich_body)
      new_attachment.blob.open(tmpdir: '/tmp') do |file|
        expect(FFMPEG::Movie.new(file.path).audio_codec).to eq('aac')
      end
    end

    context 'with video' do
      let(:blob) { create_file_blob(filename: 'video.3gp') }

      it do
        expect(FFMPEG::Movie.new('spec/fixtures/files/video.3gp').video_codec).to eq('mpeg4')
        expect { result }.to have_enqueued_job(ActiveStorage::PurgeJob)
          .and(change { section.rich_body.reload.body.to_html })
        expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
        new_attachment = ActiveStorage::Attachment.find_by(record: section.rich_body)
        new_attachment.blob.open(tmpdir: '/tmp') do |file|
          footage = FFMPEG::Movie.new(file.path)
          expect(footage.audio_codec).to eq('aac')
          expect(footage.video_codec).to eq('h264')
        end
      end
    end
  end

  context 'with non Action Text Attachment' do
    let(:vault) { user.vault }
    let(:attachment) { create :active_storage_attachment, blob: blob, record: vault }

    it do
      expect(FFMPEG::Movie.new('spec/fixtures/files/test_audio.oga').audio_codec).to eq('opus')
      expect { result }.to have_enqueued_job(ActiveStorage::PurgeJob).and change { attachment.reload.blob_id }
      attachment.blob.open(tmpdir: '/tmp') do |file|
        expect(FFMPEG::Movie.new(file.path).audio_codec).to eq('aac')
      end
    end
  end
end
