# == Schema Information
#
# Table name: families
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  old_cover      :string           default(""), not null
#  cover_image_id :integer
#  motto          :text             default(""), not null
#  storage_size   :bigint           default(0)
#  uuid           :bigint
#  ability_all    :boolean          default(TRUE), not null
#

class Family < ApplicationRecord
  include Uid

  with_options dependent: :destroy do
    has_one :vault, as: :owner, inverse_of: :owner
    has_many :subscriptions, class_name: 'FamilySubscription'
    has_many :kinships
    has_one :admin_kinship, -> { role_admin }, class_name: 'Kinship', inverse_of: :family
    has_many :co_admin_kinships, -> { role_co_admin }, class_name: 'Kinship', inverse_of: :family
    has_many :offline_members, -> { offline_members }, class_name: 'Kinship', inverse_of: :family
    has_many :invitations
    has_many :publications
    has_many :chapters, as: :chapterable
  end
  has_one :active_subscription, -> { active }, class_name: 'FamilySubscription', inverse_of: :family
  has_many :users, inverse_of: :families, through: :kinships
  has_one :admin, through: :admin_kinship, source: :user
  has_many :co_admins, through: :co_admin_kinships, source: :user
  has_many :stories, through: :publications

  has_one_attached :cover
  has_encrypted_rich_text :profile # TODO: remove after migration to description column

  validates :name, presence: true
  validates :family_type, presence: true
  validates :kinships, presence: true
  validate :admin_presence

  accepts_nested_attributes_for :kinships
  accepts_nested_attributes_for :vault

  after_commit :process_cover_variant

  def kinship_for(user)
    kinships.find_by(user_id: user.id)
  end

  def cover_image_url(size: nil)
    return cover.url if cover.present? && size.nil?

    processed_cover_url(size) if cover.present?
  end

  def processed_cover_url(size)
    cover.variant(resize_to_limit: IMAGE_SIZE[size]).processed.url
  rescue
    nil
  end

  def active?
    # %w(active trialing).include?(connector.subscription&.status)
    true
  end

  private

  def process_cover_variant
    return unless cover.attached?

    ProcessImageVariantJob.perform_later(self, :cover, [:medium])
  end

  def admin_presence
    admin_kinships = kinships.find_all { |kinship| kinship.role == 'admin' }
    errors.add(:kinship, 'with role admin is missing') if admin_kinships.count < 1
    errors.add(:kinship, 'with role admin can be only one') if admin_kinships.count > 1
  end
end
