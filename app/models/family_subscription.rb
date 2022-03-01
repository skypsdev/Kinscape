# == Schema Information
#
# Table name: family_subscriptions
#
#  id                   :uuid             not null, primary key
#  user_id              :bigint           not null
#  family_id            :bigint           not null
#  billing_plan_data    :jsonb            not null
#  stripe_id            :string
#  current_period_start :datetime
#  current_period_end   :datetime
#  cancel_at_period_end :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class FamilySubscription < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :user
  belongs_to :family

  scope :active, -> { where('current_period_start <= :time AND current_period_end >= :time', time: Time.current) }
end
