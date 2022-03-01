# == Schema Information
#
# Table name: stripe_plans
#
#  id                :bigint           not null, primary key
#  plan_id           :string
#  active            :boolean
#  nickname          :string
#  currency          :string
#  amount            :integer
#  interval          :string
#  trial_period_days :integer
#  product           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class StripePlan < ApplicationRecord
  validates :plan_id, presence: true, uniqueness: true
  validate :check_active, on: :update

  private

  def check_active
    return unless active_changed?
    return unless active
    return unless StripePlan.find_by(active: true)

    errors.add(:active, 'already exists')
  end
end
