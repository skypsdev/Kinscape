FactoryBot.define do
  factory :box do
    sequence(:name) { |n| "Box name #{n}" }
    vault
  end
end
