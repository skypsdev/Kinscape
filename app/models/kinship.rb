class Kinship < ApplicationRecord
  include RoleEnum
  include AccessEnum
  include Showcase

  belongs_to :family
  belongs_to :user, optional: true
  belongs_to :inviter, optional: true, class_name: 'User'
  has_many :publications, dependent: :restrict_with_exception

  validates :nickname, presence: true
  validates :user, uniqueness: { scope: :family, allow_blank: true }
  validates :role, uniqueness: { scope: :family, message: 'admin is already present' }, if: -> { role_admin? }
  validate :attributes_change

  has_one_attached :avatar

  with_options dependent: :destroy do
    has_many :chapters, as: :chapterable
    has_many :all_comments, class_name: 'Comment', as: :top_commentable
  end

  delegate :name, to: :family, prefix: true
  delegate :name, to: :user, prefix: true

  alias_attribute :name, :nickname

  def avatar_url(size: nil)
    return unless avatar.attached?
    return Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: true) unless size

    Rails.application.routes.url_helpers.rails_representation_url(
      avatar.variant(resize_to_limit: IMAGE_SIZE[size]),
      only_path: true
    )
  end

  private

  def attributes_change
    return unless Kinship.method_defined?(:access_type)

    errors.add(:access_type, '- attribute change not allowed') if access_type_changed? && persisted?
    errors.add(:role, '- attribute change not allowed') if role_changed? && access_type != 'default' && persisted?
  end
end
