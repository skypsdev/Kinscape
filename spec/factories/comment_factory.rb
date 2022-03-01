# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text             not null
#  commentable_type :string           not null
#  commentable_id   :integer          not null
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  uuid             :bigint
#

FactoryBot.define do
  factory :comment do
    body { 'Hello world' }
    association :commentable, factory: :publication
    user
    publication
  end
end
