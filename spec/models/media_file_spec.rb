# == Schema Information
#
# Table name: media_files
#
#  id             :integer          not null, primary key
#  mimetype       :string
#  url            :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  filename       :text             default(""), not null
#  key            :string           default(""), not null
#  type           :string
#  height         :integer
#  width          :integer
#  converted_urls :hstore
#  user_id        :integer
#  size           :integer
#  title          :string
#

require 'spec_helper'

describe MediaFile, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to allow_value('https://foo.com/bar.png').for(:url) }
    it { is_expected.to allow_value('https://foo.com/bar/baz.png').for(:url) }
    it { is_expected.not_to allow_value('ftp://foo.com/bar.png').for(:url) }
  end

  describe '#s3_url' do
    it 'returns fully qualified S3 url' do
      s3_path = '/some_dir/abc_some_file.png'
      media_file = described_class.new(key: s3_path)

      expect(media_file.s3_url)
        .to eq "https://s3-us-west-2.amazonaws.com/kinscape-test/#{s3_path}"
    end
  end

  describe '#cdn_url' do
    let(:cloudfront) { 'https://d2e2dk7751ymam.cloudfront.net' }

    context 'when format undefined' do
      let(:media_file) do
        create :media_file, type: 'Image', key: 'vault/eC3_10 2.jpg'
      end

      it { expect(media_file.cdn_url).to eq "#{cloudfront}/vault/eC3_10%202.jpg" }
    end

    context 'when format defined but converted format URL does not exist' do
      let(:url) { 'https://placehold.it/vault/eC3_10 2.jpg' }

      let(:media_file) do
        create :media_file,
               type: 'Image',
               key: 'vault/eC3_10 2.jpg',
               url: url,
               converted_urls: {}
      end

      it 'returns correct URL' do
        expect(media_file.cdn_url(format: 'medium')).to eq(
          "https://s3-us-west-2.amazonaws.com/kinscape-test/#{media_file.key}"
        )
      end
    end

    context 'when format defined and converted path exists' do
      let(:url) { 'https://placehold.it/vault/eC3_10 2.jpg' }
      let(:media_file) do
        create :media_file,
               type: 'Image',
               key: 'vault/eC3_10 2.jpg',
               url: url,
               converted_urls: { medium: 'vault/medium/eC3_10 2.jpg' }
      end

      it { expect(media_file.cdn_url(format: 'medium')).to eq "#{cloudfront}/vault/medium/eC3_10%202.jpg" }
    end

    context 'when format defined,converted path exists and starts with slash' do
      let(:url) { 'https://placehold.it/vault/eC3_10 2.jpg' }

      let(:media_file) do
        create :media_file,
               type: 'Image',
               key: 'vault/eC3_10 2.jpg',
               url: url,
               converted_urls: { medium: '/vault/medium/eC3_10 2.jpg' }
      end

      it { expect(media_file.cdn_url(format: 'medium')).to eq "#{cloudfront}/vault/medium/eC3_10%202.jpg" }
    end

    context 'when format defined and converted URL exists' do
      let(:url) { 'https://placehold.it/vault/eC3_10 [2].jpg' }

      let(:media_file) do
        create :media_file,
               type: 'Image',
               key: 'vault/eC3_10 2.jpg',
               url: url,
               converted_urls: {
                 medium: 'https://s3.com/vault/medium/eC3_10 [2].jpg'
               }
      end

      it { expect(media_file.cdn_url(format: 'medium')).to eq 'https://s3.com/vault/medium/eC3_10 [2].jpg' }
    end
  end
end
