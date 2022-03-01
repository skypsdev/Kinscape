# == Schema Information
#
# Table name: appreciations
#
#  id               :bigint           not null, primary key
#  appreciable_type :string           not null
#  appreciable_id   :bigint           not null
#  user_id          :bigint           not null
#  reaction         :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryBot.define do
  factory :appreciation do
    association :appreciable, factory: :story
    user
    reaction { 0 }
  end
end
