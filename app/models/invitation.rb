class Invitation < ApplicationRecord
  include RoleEnum
  include Showcase

  before_validation :downcase_email

  belongs_to :family
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User', optional: true
  belongs_to :kinship, optional: true, autosave: true

  validates :email, presence: true, email: true, uniqueness: { scope: :family_id }

  delegate :name, to: :family, prefix: true

  accepts_nested_attributes_for :recipient

  scope :pending, -> { where(accepted_at: nil) }

  def downcase_email
    self.email = email.strip.downcase if email.present?
  end
end
