require 'spec_helper'

RSpec.describe ActiveStorage::ConvertVideoJob, type: :job do
  subject(:job) { described_class.perform_later(attachment) }

  let(:blob) { create_file_blob(filename: 'mpeg4.wmv') }
  let!(:attachment) { create :active_storage_attachment, blob: blob }

  it do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    expect(FFMPEG::Movie.new('spec/fixtures/files/mpeg4.wmv').video_codec).to eq('msmpeg4v3')
    expect { job }.to have_performed_job
      .with(attachment)
      .and(change { attachment.reload.blob_id })
    attachment.blob.open(tmpdir: '/tmp') do |file|
      expect(FFMPEG::Movie.new(file.path).video_codec).to eq('h264')
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
