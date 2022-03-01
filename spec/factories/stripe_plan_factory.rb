# == Schema Information
#
# Table name: stripe_plans
#
#  id                :bigint           not null, primary key
#  plan_id           :string
#  active            :boolean
#  nickname          :string
#  currency          :string
#  amount            :integer
#  interval          :string
#  trial_period_days :integer
#  product           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryBot.define do
  factory :stripe_plan do
    sequence(:plan_id) { |n| "plan_#{n}" }
    sequence(:nickname) { |n| "Plan #{n}" }
    currency { 'usd' }
    sequence(:amount) { |n| n * 1000 }
    interval { 'year' }
    trial_period_days { 30 }
    product { 'stripe_product_id' }
    active { false }
  end
end
