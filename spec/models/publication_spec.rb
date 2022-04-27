require 'spec_helper'

RSpec.describe Publication, type: :model do
  describe '#time_capsules' do
    let(:user) { create :user }
    let(:family) { create :family, users: [user] }
    let(:story) { create :story, user: user }

    before do
      # published
      build(:publication, publish_on: 1.day.ago,
                          notified_at: 1.day.ago,
                          story: story,
                          kinship: family.kinship_for(story.user),
                          family: family).save validate: false

      # ordinary_publication
      create :publication, publish_on: nil,
                           family: family,
                           story: story,
                           notified_at: 1.day.ago
      # not notified
      build(:publication, publish_on: 1.day.ago,
                          notified_at: nil,
                          story: story,
                          kinship: family.kinship_for(story.user),
                          family: family).save validate: false

      # scheduled
      create :publication, publish_on: 1.day.from_now,
                           story: story,
                           family: family,
                           notified_at: 1.day.from_now
    end

    it 'returns unpublished or unnotified time capsules' do
      expect(described_class.time_capsules.count).to eq(1)
    end
  end
end
