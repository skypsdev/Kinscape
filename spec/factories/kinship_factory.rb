# == Schema Information
#
# Table name: kinships
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  family_id       :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  nickname        :string
#  location        :string
#  birth_date      :string
#  birth_place     :string
#  address         :string
#  phone           :string
#  email           :string
#  death_date      :string
#  media_avatar_id :integer
#  role            :string           default("guest"), not null
#

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
  end
end
