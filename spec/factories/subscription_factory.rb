FactoryBot.define do
  factory :subscription do
    user
    status { 'trialing' }
    trial_end { '2027-05-18 19:50:08' }
    billing_plan_data { '' }
  end
end
