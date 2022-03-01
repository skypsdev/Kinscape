# == Schema Information
#
# Table name: vaults
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  family_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :bigint
#

FactoryBot.define do
  factory :vault do
    association :owner, factory: :user
  end
end
