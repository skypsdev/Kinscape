require 'spec_helper'

describe Stories::DuplicationService do
  subject(:result) { described_class.call(story, community_type: community_type) }

  let(:community_type) { false }
  let(:user) { create :user }
  let(:admin) { nil }
  let(:story) { create :story, user: user }
  let(:publication) { nil }

  before { create :section, story: story }

  context 'story with all data' do
    it 'duplicates the cover image' do
      expect { result }.to have_enqueued_job(CopySectionsJob).once
      expect(result).to be_persisted
      expect(result.id).not_to eq story.id
      expect(result.title).to eq "Copy #{story.title}"
      expect(result.cover).not_to be story.cover
      expect(result.cover_url).to eq story.cover_url
    end

    context 'with community_type' do
      let(:community_type) { true }
      let!(:story_title) { story.title }

      it do
        expect { result }.to have_enqueued_job(CopySectionsJob).once
        expect(result.title).to eq story_title
        expect(story.reload.title).to eq "Copy #{story_title}"
        expect(result.original_story).to eq story
      end
    end
  end

  context 'story without cover image' do
    it 'has no cover image' do
      expect { result }.to have_enqueued_job(CopySectionsJob).once
      expect(result).to be_persisted
      expect(result.id).not_to eq story.id
      expect(result.title).to eq "Copy #{story.title}"
      expect(result.cover.attached?).to eq false
    end
  end

  context 'copy as community story' do
    subject(:result) do
      described_class.call(story, community_type: community_type, user: admin, publication: publication)
    end

    let(:admin) { create :user }
    let(:family) { create :family, users: [admin, user] }
    let!(:publications) do
      stub_mandrill
      ::Publications::CreationService.call(story, user, { share_type: :community, families_ids: [family.id] })
    end
    let(:publication) { publications.first }

    it 'create duplicate story for community' do
      expect { result }.to have_enqueued_job(CopySectionsJob).once.and change(Publication, :count).by(1)
      expect(story.reload.title).to eq story.title
      expect(result.original_story).to eq story
      expect(result.user).to eq admin
    end
  end
end
