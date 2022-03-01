# == Schema Information
#
# Table name: invitations
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  family_id    :integer          not null
#  sender_id    :integer          not null
#  recipient_id :integer
#  email        :string           not null
#  accepted_at  :datetime
#  message      :text             default(""), not null
#  first_name   :string
#  last_name    :string
#  role         :string           default("member"), not null
#

FactoryBot.define do
  factory :invitation do
    association :sender, factory: :user
    sequence(:email) { |n| "user#{n}@example.com" }
    family
  end
end
