require 'spec_helper'
require './lib/s3_config'

describe S3Config do
  describe '.cloudfront_endpoint' do
    it 'returns the base url' do
      expect(described_class.cloudfront_endpoint).to \
        eq 'https://d2e2dk7751ymam.cloudfront.net'
    end
  end

  describe '.base_url' do
    it 'returns the base url' do
      expect(described_class.base_url).to eq 'https://s3-us-west-2.amazonaws.com'
    end
  end

  describe '.bucket' do
    it 'returns the bucket for test env' do
      allow(ENV).to receive(:[]).with('RAILS_ENV').and_return('test')

      expect(described_class.bucket).to eq 'kinscape-test'
    end

    it 'returns the bucket for stagingt env' do
      allow(ENV).to receive(:[]).with('RAILS_ENV').and_return('staging')

      expect(described_class.bucket).to eq 'kinscape-staging'
    end
  end
end
