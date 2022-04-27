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
