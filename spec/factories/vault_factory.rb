FactoryBot.define do
  factory :vault do
    association :owner, factory: :user
  end
end
