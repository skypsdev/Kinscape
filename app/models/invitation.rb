# == Schema Information
#
# Table name: invitations
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  family_id    :integer          not null
#  sender_id    :integer          not null
#  recipient_id :integer
#  email        :string           not null
#  accepted_at  :datetime
#  message      :text             default(""), not null
#  first_name   :string
#  last_name    :string
#  role         :string           default("member"), not null
#

class Invitation < ApplicationRecord
  self.implicit_order_column = :created_at

  include RoleEnum

  before_create :downcase_email

  belongs_to :family
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User', optional: true
  belongs_to :kinship, optional: true, autosave: true

  validates :email, presence: true, email: true, uniqueness: { scope: :family_id }

  delegate :name, to: :family, prefix: true
  delegate :name, to: :sender, prefix: true

  accepts_nested_attributes_for :recipient

  scope :pending, -> { where(accepted_at: nil) }

  def accepted?
    accepted_at.present?
  end

  def downcase_email
    email.downcase! if email.present?
  end
end
