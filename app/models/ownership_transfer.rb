class OwnershipTransfer < ApplicationRecord
  belongs_to :family
  belongs_to :old_admin, class_name: 'User'
  belongs_to :new_admin, class_name: 'User'

  enum status: {
    pending: 'pending',
    accepted: 'accepted',
    declined: 'declined'
  }, _prefix: true
end
