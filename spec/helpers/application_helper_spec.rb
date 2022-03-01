require 'spec_helper'

describe ApplicationHelper, type: :helper do
  describe 'background_image_css' do
    it 'returns empty string if url is blank' do
      expect(helper.background_image_css(nil)).to eq ''
    end

    it 'returns build background-image styles if url is present' do
      image_url = 'https://example.com/image.png'

      expect(helper.background_image_css(image_url)).to \
        eq "background-image: url(#{image_url});"
    end
  end
end
