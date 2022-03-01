require 'spec_helper'

describe Converter::ImageService do
  let(:file) { build(:image, url: 'https://placehold.it/99x') }
  let(:convert_image) { described_class.new(file) }
  let(:requests) { stub_image_convert('https://placehold.it/99x') }

  before { described_class.test = false }

  describe '#convert' do
    # TODO-VCR: make a real request
    it 'calls #convert_format for each format' do
      allow(convert_image).to receive(:convert_format)
      convert_image.convert
      expect(requests[:medium]).to have_been_requested
      expect(requests[:collage]).to have_been_requested
      expect(convert_image).to have_received(:convert_format).exactly(Image.formats.size).times
    end
  end

  describe '#convert_format' do
    # TODO-VCR: make a real request
    it 'makes a call out to filepicker' do
      convert_image.convert_format(:medium, width: 500, height: 500)

      expect(requests[:medium]).to have_been_requested
      expect(requests[:collage]).not_to have_been_requested
    end
  end
end
