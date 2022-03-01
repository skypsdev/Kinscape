# == Schema Information
#
# Table name: subscriptions
#
#  id                   :integer          not null, primary key
#  user_id              :integer          not null
#  billing_plan_data    :text             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  status               :string
#  stripe_id            :string
#  trial_end            :datetime
#  trial_start          :datetime
#  current_period_start :datetime
#  current_period_end   :datetime
#  cancel_at_period_end :boolean
#

FactoryBot.define do
  factory :subscription do
    user
    status { 'trialing' }
    trial_end { '2027-05-18 19:50:08' }
    billing_plan_data { '' }
  end
end
