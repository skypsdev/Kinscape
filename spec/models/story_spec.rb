# == Schema Information
#
# Table name: stories
#
#  id                  :integer          not null, primary key
#  title               :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  date                :string           default(""), not null
#  description         :text             default(""), not null
#  user_id             :integer          not null
#  tags                :string           default([]), is an Array
#  cover_image_id      :integer
#  start_year          :string
#  start_month         :string
#  start_day           :string
#  end_year            :string
#  end_month           :string
#  end_day             :string
#  is_range            :boolean          default(FALSE)
#  date_as_text        :string           default(""), not null
#  comments_count      :integer          default(0), not null
#  appreciations_count :bigint           default(0)
#  sections_count      :integer          default(0), not null
#  contributors_count  :integer          default(0), not null
#  uuid                :bigint
#  aws                 :boolean
#  original_story_id   :integer
#

require 'spec_helper'

describe Story, type: :model do
  it_behaves_like 'uuidable'

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

  describe '.published' do
    it 'returns only published stories' do
      family = create(:family)
      create(:story)
      story_2 = create(:story, families: [family])

      expect(described_class.published).to eq [story_2]
    end
  end

  describe '.draft' do
    it 'returns only unpublished stories' do
      family = create(:family)
      story_1 = create(:story)
      create(:story, families: [family])

      expect(described_class.draft).to eq [story_1]
    end
  end

  describe '.time_capsule' do
    subject(:story) { create :story, publications: [publication] }

    let(:family) { create :family }
    let(:publication) do
      build :publication, publish_on: 1.day.from_now, family: family
    end

    it 'returns a scheduled publication' do
      expect(story.time_capsule).to eq publication
    end
  end

  describe '.time_capsule?' do
    subject(:story) { create :story, publications: [publication] }

    let(:family) { create :family }

    context 'when story publication is scheduled' do
      let(:publication) do
        build :publication, publish_on: 1.day.from_now, family: family
      end

      it 'returns true' do
        expect(story.time_capsule?).to eq true
      end
    end

    context 'when story is published' do
      let(:publication) { build :publication, family: family }

      it 'returns false' do
        expect(story.time_capsule?).to eq false
      end
    end
  end

  describe '.time_capsule_released?' do
    subject(:story) { create :story, publications: [publication] }

    let(:family) { create :family }
    let(:publication) do
      build :publication, publish_on: 1.day.from_now, family: family
    end

    context 'when story publication date is in future' do
      it 'returns false' do
        expect(story.time_capsule_released?).to eq false
      end
    end

    context 'when story publication date has passed' do
      it 'returns true' do
        expect(story.time_capsule_released?).to eq false

        Timecop.travel 2.days.from_now do
          expect(story.time_capsule_released?).to eq true
        end
      end
    end
  end

  it_behaves_like 'appreciable'

  describe '.delete_all_contents_by_author' do
    it 'deletes all the contents by the author' do
      story = create(:story)
      author = create(:user)
      section = create(:section, story: story, author: author)
      appreciation = create(:appreciation, appreciable: story, user: author)
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
      create :appreciation, appreciable: story
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
        .by(-1)
    end
  end
end
