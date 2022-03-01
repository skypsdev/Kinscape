FactoryBot.define do
  factory :ownership_transfer do
    association :new_admin, factory: :user
    association :old_admin, factory: :user
    family
  end
end
