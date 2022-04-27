require 'spec_helper'

describe ::Stories::UpdatingService do
  subject(:result) { described_class.call(story, params) }

  let(:image_blob) { create_file_blob }
  let(:story) { create :story, cover: image_blob.signed_id, category_list: %w[summer sun] }

  context 'with categories' do
    let(:params) { { categories: %w[winter sun] } }

    it 'does update the story' do
      expect(result.valid?).to eq(true)
      expect(story.reload.category_list).to contain_exactly('winter', 'sun')
    end
  end

  context 'when a nil is passed' do
    let(:params) { { title: nil, cover: nil } }

    it 'does update the story' do
      expect { result }
        .to change(story, :title)
        .and change(story, :cover_url)
    end
  end

  context 'when an html element is passed' do
    let(:params) { { title: 'To be<br>or not<br>to be' } }

    it 'strips and updates the title' do
      expect { result }
        .to change(story, :title)
        .and avoid_changing(story, :cover_url)
      expect(result.valid?).to eq(true)
      expect(story.title).to eq 'To be or not to be'
    end
  end

  context 'when html entities are passed' do
    let(:params) { { title: 'Lilo &amp; Stitch' } }

    it 'updates the title' do
      expect(result.valid?).to eq(true)
      expect(story.title).to eq 'Lilo & Stitch'
    end
  end

  context 'when an ampersand is passed in the title' do
    let(:params) { { title: 'Lilo & Stitch' } }

    it 'updates the title' do
      expect(result.valid?).to eq(true)
      expect(story.title).to eq 'Lilo & Stitch'
    end
  end
end
