FactoryBot.define do
  factory :appreciation do
    association :appreciable, factory: :publication
    user
    reaction { 0 }
  end
end
