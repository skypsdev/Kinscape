FactoryBot.define do
  factory :story do
    sequence(:title) { |n| "title #{n}" }
    user
  end
end
