class FamilySubscription < ApplicationRecord
  belongs_to :user
  belongs_to :family

  scope :active, -> { where('current_period_start <= :time AND current_period_end >= :time', time: Time.current) }
end
