# == Schema Information
#
# Table name: family_subscriptions
#
#  id                   :uuid             not null, primary key
#  user_id              :bigint           not null
#  family_id            :bigint           not null
#  billing_plan_data    :jsonb            not null
#  stripe_id            :string
#  current_period_start :datetime
#  current_period_end   :datetime
#  cancel_at_period_end :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
FactoryBot.define do
  factory :family_subscription do
    user
    family
  end
end
