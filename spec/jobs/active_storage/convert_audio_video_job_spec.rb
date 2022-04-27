require 'spec_helper'

RSpec.describe ActiveStorage::ConvertAudioVideoJob, type: :job do
  subject(:job) { described_class.perform_later(attachment) }

  let(:blob) { create_file_blob(filename: 'test_audio.oga', content_type: 'audio/mpeg') }

  let!(:attachment) { create :active_storage_attachment, blob: blob }

  it do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    expect(FFMPEG::Movie.new('spec/fixtures/files/test_audio.oga').audio_codec).to eq('opus')
    expect { job }.to have_performed_job
      .with(attachment)
      .and(change { attachment.reload.blob_id })
    attachment.blob.open(tmpdir: '/tmp') do |file|
      expect(FFMPEG::Movie.new(file.path).audio_codec).to eq('aac')
      expect(FFMPEG::Movie.new(file.path).video_codec).to be_nil
    end
  end

  context 'with video' do
    let(:blob) { create_file_blob(filename: 'video.3gp') }

    it do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      expect(FFMPEG::Movie.new('spec/fixtures/files/video.3gp').video_codec).to eq('mpeg4')
      expect { job }.to have_performed_job
        .with(attachment)
        .and(change { attachment.reload.blob_id })
      attachment.blob.open(tmpdir: '/tmp') do |file|
        expect(FFMPEG::Movie.new(file.path).video_codec).to eq('h264')
        expect(FFMPEG::Movie.new(file.path).audio_codec).to eq('aac')
      end
    end
  end

  context 'with audio_stored_as_video' do
    let(:blob) { create_file_blob(filename: 'audio_stored_as_video.webm') }

    it do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      expect(FFMPEG::Movie.new('spec/fixtures/files/audio_stored_as_video.webm').audio_codec).to eq('opus')
      expect { job }.to have_performed_job
        .with(attachment)
        .and(change { attachment.reload.blob_id })
      attachment.blob.open(tmpdir: '/tmp') do |file|
        expect(FFMPEG::Movie.new(file.path).audio_codec).to eq('aac')
        expect(FFMPEG::Movie.new(file.path).video_codec).to be_nil
      end
    end
  end

  context 'with image' do
    let(:blob) { create_file_blob(filename: 'image.jpg') }

    it do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      expect { job }.to(avoid_changing { attachment.reload.blob_id })
    end
  end
end
