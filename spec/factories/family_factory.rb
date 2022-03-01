# == Schema Information
#
# Table name: families
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  old_cover      :string           default(""), not null
#  cover_image_id :integer
#  motto          :text             default(""), not null
#  storage_size   :bigint           default(0)
#  uuid           :bigint
#  ability_all    :boolean          default(TRUE), not null
#

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
