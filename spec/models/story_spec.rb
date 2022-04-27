require 'spec_helper'

describe Story, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:sections) }
    it { is_expected.to have_many(:comments) }
    it { is_expected.to have_many(:family_members) }
    it { is_expected.to have_many(:publications) }
    it { is_expected.to belong_to(:original_story).optional }
    it { is_expected.to have_many(:shared_stories) }
  end

  describe '.chronological' do
    it 'returns stories by earliest created_at' do
      story_1 = create(:story, created_at: 2.days.ago)
      story_2 = create(:story, created_at: 0.days.ago)
      story_3 = create(:story, created_at: 1.day.ago)

      expect(described_class.chronological).to eq [story_2, story_3, story_1]
    end
  end

  it_behaves_like 'appreciable'

  describe '.delete_all_contents_by_author' do
    it 'deletes all the contents by the author' do
      story = create(:story)
      author = create(:user)
      section = create(:section, story: story, author: author)
      appreciation = create(:appreciation, appreciable: section, user: author)
      comment = create(:comment, commentable: section, user: author)

      story.delete_all_contents_by_author(author)

      expect(story.sections).not_to include section
      expect(story.appreciations).not_to include appreciation
      expect(story.comments).not_to include comment
    end
  end

  describe 'delete story' do
    let(:story) { create :story }
    let(:section) { create :section, story: story }

    before do
      create :comment, commentable: section
      create :appreciation, appreciable: section
      create :publication, story: story
    end

    it do
      expect { story.destroy }.to change(Section, :count)
        .by(-1)
        .and change(Comment, :count)
        .by(-1)
        .and change(Appreciation, :count)
        .by(-1)
        .and change(Publication, :count)
        .by(-2)
    end
  end
end
