class Family < ApplicationRecord
  include AccessEnum
  include Showcase

  with_options dependent: :destroy do
    has_one :vault, as: :owner, inverse_of: :owner
    has_many :subscriptions, class_name: 'FamilySubscription'
    has_many :kinships
    has_one :admin_kinship, -> { role_admin }, class_name: 'Kinship', inverse_of: :family
    has_many :co_admin_kinships, -> { role_co_admin }, class_name: 'Kinship', inverse_of: :family
    has_many :offline_members, -> { role_offline_member }, class_name: 'Kinship', inverse_of: :family
    has_many :invitations
    has_many :publications
    has_many :chapters, as: :chapterable
    has_many :all_comments, class_name: 'Comment', as: :top_commentable
  end
  has_one :active_subscription, -> { active }, class_name: 'FamilySubscription', inverse_of: :family
  has_many :users, inverse_of: :families, through: :kinships
  has_one :admin, through: :admin_kinship, source: :user
  has_many :co_admins, through: :co_admin_kinships, source: :user
  has_many :stories, through: :publications

  has_one_attached :cover

  validates :name, presence: true
  validates :family_type, presence: true
  validates :kinships, presence: true
  validate :admin_presence
  validate :personal_not_changed

  accepts_nested_attributes_for :kinships
  accepts_nested_attributes_for :vault

  after_create :create_vault

  def kinship_for(user)
    kinships.find_by(user_id: user.id)
  end

  def cover_image_url(size: nil)
    return unless cover.attached?
    return Rails.application.routes.url_helpers.rails_blob_url(cover, only_path: true) unless size

    Rails.application.routes.url_helpers.rails_representation_url(
      cover.variant(resize_to_limit: IMAGE_SIZE[size]),
      only_path: true
    )
  end

  def active?
    # %w(active trialing).include?(connector.subscription&.status)
    true
  end

  private

  def create_vault
    create_vault! if default_access?
  end

  def admin_presence
    admin_kinships = kinships.find_all { |kinship| kinship.role == 'admin' }
    errors.add(:kinship, 'with role admin is missing') if admin_kinships.count < 1
    errors.add(:kinship, 'with role admin can be only one') if admin_kinships.count > 1
  end

  def personal_not_changed
    errors.add(:access_type, '- attribute change not allowed') if access_type_changed? && persisted?
  end
end
