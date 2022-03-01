require 'spec_helper'

describe Stories::DuplicationService do
  subject(:result) { described_class.call(story, community_type: community_type) }

  let(:community_type) { false }

  shared_examples 'duplicates story, its sections and media files' do
    it 'is persisted' do
      expect(result).to be_persisted
    end

    it 'has a different id' do
      expect(result.id).not_to eq story.id
    end

    it 'duplicates sections' do
      expect(result.sections.count).to eq 1
    end

    it 'duplicates the media_files on the sections' do
      expect(result.sections.first.media_files.count).to eq 1
    end

    it 'has Copy prefix' do
      expect(result.title).to eql "Copy #{story.title}"
    end
  end

  before { create :section, story: story }

  context 'story with all data' do
    let(:story) { create :story }

    it_behaves_like 'duplicates story, its sections and media files'

    it 'duplicates the cover image' do
      expect(result.cover).not_to be story.cover
      expect(result.cover_url).to eq story.cover_url
    end

    context 'with community_type' do
      let(:community_type) { true }

      it do
        expect(result.title).to eq story.title
        expect(result.original_story).to eq story
      end
    end
  end

  context 'story without cover image' do
    let(:story) { create :story }

    it_behaves_like 'duplicates story, its sections and media files'

    it 'has no cover image' do
      expect(result.cover.attached?).to eq false
    end
  end
end
