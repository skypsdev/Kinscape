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
