# == Schema Information
#
# Table name: ownership_transfers
#
#  id           :uuid             not null, primary key
#  old_admin_id :bigint           not null
#  new_admin_id :bigint           not null
#  family_id    :bigint           not null
#  expires_at   :datetime
#  status       :string           default("pending"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class OwnershipTransfer < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :family
  belongs_to :old_admin, class_name: 'User'
  belongs_to :new_admin, class_name: 'User'

  enum status: {
    pending: 'pending',
    accepted: 'accepted',
    declined: 'declined'
  }, _prefix: true
end
