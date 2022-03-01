# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  confirmation_token :string(128)
#  remember_token     :string(128)      not null
#  old_avatar         :string           default(""), not null
#  metadata           :hstore
#  tour_completed     :boolean
#  first_name         :string
#  last_name          :string
#  avatar_id          :integer
#  caretaker_id       :integer
#  title              :string
#  confirmed_at       :datetime
#  admin              :boolean          default(FALSE)
#  stripe_id          :string
#  storage_size       :bigint           default(0)
#  uuid               :bigint
#  ability_all        :boolean          default(TRUE), not null
#

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    confirmed_at { 1.day.ago }
    ability_all { false }
    remember_token { SecureRandom.uuid }
  end
end
