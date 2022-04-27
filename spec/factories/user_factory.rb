FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    confirmed_at { 1.day.ago }
    ability_all { false }
    remember_token { SecureRandom.uuid }
    terms_and_conditions { true }
  end
end
