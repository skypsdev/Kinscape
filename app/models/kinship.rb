# == Schema Information
#
# Table name: kinships
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  family_id       :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  nickname        :string
#  location        :string
#  birth_date      :string
#  birth_place     :string
#  address         :string
#  phone           :string
#  email           :string
#  death_date      :string
#  media_avatar_id :integer
#  role            :string           default("guest"), not null
#

require 'filestack_config'

class Kinship < ApplicationRecord
  include RoleEnum

  belongs_to :family
  belongs_to :user, optional: true
  belongs_to :inviter, optional: true, class_name: 'User'

  validates :nickname, presence: true
  validates :user, uniqueness: { scope: :family, allow_blank: true }
  validates :role, uniqueness: { scope: :family, message: 'admin is already present' }, if: -> { role_admin? }

  scope :offline_members, -> { where(user_id: nil) }

  has_one_attached :avatar
  has_encrypted_rich_text :rich_profile
  has_many :chapters, as: :chapterable, dependent: :destroy

  delegate :name, to: :family, prefix: true
  delegate :name, to: :user, prefix: true

  alias_attribute :name, :nickname

  after_commit :process_avatar_variant

  # DEPRECATED BEGIN
  belongs_to :media_avatar, class_name: 'Avatar', optional: true
  accepts_nested_attributes_for :media_avatar, allow_destroy: true
  # DEPRECATED END

  def avatar_url(size: nil)
    if avatar.attached?
      return avatar.url if size.nil?

      avatar.variant(resize_to_limit: IMAGE_SIZE[size]).processed.url
    elsif media_avatar.present?
      return media_avatar.url if size.nil?

      media_avatar.cdn_url(format: size)
    end
  end

  private

  def process_avatar_variant
    return unless avatar.attached?

    ProcessImageVariantJob.perform_later(self, :avatar, [:medium, :thumb])
  end
end
