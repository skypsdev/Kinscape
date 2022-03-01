# == Schema Information
#
# Table name: boxes
#
#  id         :integer          not null, primary key
#  name       :text             default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vault_id   :integer
#  user_id    :integer
#  uuid       :bigint
#

FactoryBot.define do
  factory :box do
    sequence(:name) { |n| "Box name #{n}" }
    vault
  end
end
