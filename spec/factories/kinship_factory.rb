FactoryBot.define do
  factory :kinship do
    nickname { Faker::Name.first_name }
    user
    family
    role { :member }
  end

  factory :offline_member, class: 'Kinship' do
    nickname { Faker::Name.first_name }
    family
    role { :offline_member }
  end

  factory :follower, class: 'Kinship' do
    nickname { Faker::Name.first_name }
    user
    family
    role { :guest }
    access_type { :personal }
  end
end
