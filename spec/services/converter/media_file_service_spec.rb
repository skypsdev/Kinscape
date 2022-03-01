require 'spec_helper'

describe Converter::MediaFileService do
  let(:video_file) do
    create :video_media_file,
           id: 100_500,
           type: 'Video',
           url: 'https://valid.some_filepicker_url.com',
           key: 'test.avi'
  end

  describe '#convert' do
    subject(:converted_file) { described_class.new(video_file).convert }

    it 'makes a call out to zencoder' do
      # TODO-VCR: make a real request
      stub_request(:post, 'https://app.zencoder.com/api/v2/jobs')
      converted_file
    end
  end

  describe '#converted_urls' do
    subject(:converted_urls) { described_class.new(video_file).converted_urls }

    it 'returns a hash of urls' do
      # TODO-VCR: make a real request
      stub_request(:post, 'https://app.zencoder.com/api/v2/jobs')
      expect(converted_urls).to eq(
        mp4: 'https://s3-us-west-2.amazonaws.com/kinscape-test/test-converted.mp4',
        webm: 'https://s3-us-west-2.amazonaws.com/kinscape-test/test-converted.webm',
        thumbnail: 'https://s3-us-west-2.amazonaws.com/kinscape-test/attic/100500-thumbnail.png'
      )
    end
  end
end
