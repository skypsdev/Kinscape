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

FactoryBot.define do
  factory :publication do
    family
    story
  end
end
