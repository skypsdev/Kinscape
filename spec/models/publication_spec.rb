# == Schema Information
#
# Table name: publications
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  family_id           :integer
#  story_id            :integer          not null
#  publish_on          :date
#  notified_at         :datetime
#  share_type          :string           default("community"), not null
#  comments_count      :integer          default(0), not null
#  appreciations_count :integer          default(0), not null
#

require 'spec_helper'

RSpec.describe Publication, type: :model do
  describe '#time_capsules' do
    let(:family) { create :family }
    let(:story) { create :story }

    before do
      # published
      build(:publication, publish_on: 1.day.ago,
                          notified_at: 1.day.ago,
                          story: story,
                          family: family).save validate: false

      # ordinary_publication
      create :publication, publish_on: nil,
                           family: family,
                           story: story,
                           notified_at: 1.day.ago
      # unnotified
      build(:publication, publish_on: 1.day.ago,
                          notified_at: nil,
                          story: story,
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
