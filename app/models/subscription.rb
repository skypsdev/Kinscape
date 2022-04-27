class Subscription < ApplicationRecord
  belongs_to :user

  scope :active, -> { where('current_period_start <= :time AND current_period_end >= :time', time: Time.current) }

  serialize :billing_plan_data, JSON

  def canceled?
    cancel_at_period_end
  end

  def trialing?
    status == 'trialing'
  end

  def trial_days
    (trial_end.to_date - Time.zone.now.to_date).to_i if trial_end
  end

  def active?
    # Temp. remove payment feature
    # status == 'active'
    true
  end

  def trial_past_due?
    # Temp. remove payment feature
    # status == 'past_due'
    true
  end

  def plan_id
    billing_plan_data['id']
  end

  def group_plan?
    plan_id == ENV['STRIPE_GROUP_PLAN_ID']
  end

  def individual_plan?
    plan_id == ENV['STRIPE_INDIVIDUAL_PLAN_ID']
  end
end
