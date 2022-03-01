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

FactoryBot.define do
  factory :story do
    sequence(:title) { |n| "title #{n}" }
    user
  end
end
