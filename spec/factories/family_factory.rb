FactoryBot.define do
  factory :family do
    name { 'Test family' }
    ability_all { false }

    after(:build) do |family, evaluator|
      if evaluator.users.any?
        family.users = evaluator.users
      else
        user = FactoryBot.build(:user)
        family.users = [user]
      end
      family.kinships.first.role = :admin
      family.kinships.each do |k|
        k.nickname = k.user.first_name
        next if k.role == 'admin'

        k.role = :member
      end
    end
  end
end
