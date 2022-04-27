FactoryBot.define do
  factory :invitation do
    association :sender, factory: :user
    sequence(:email) { |n| "user#{n}@example.com" }
    family
  end
end
