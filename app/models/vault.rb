# == Schema Information
#
# Table name: vaults
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  family_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :bigint
#

class Vault < ApplicationRecord
  OWNER_TYPES = %w(User Family).freeze

  belongs_to :owner, polymorphic: true
  belongs_to :family, -> { where(vaults: { owner_type: 'Family' }) },
             optional: true,
             foreign_key: :owner_id,
             inverse_of: :vault

  has_many :boxes,
           -> { order('boxes.created_at') },
           dependent: :destroy,
           inverse_of: :vault
  has_many :root_boxes, -> { where(parent_box_id: nil).order('boxes.created_at') },
           class_name: 'Box',
           dependent: :destroy,
           inverse_of: :vault

  validates :owner_type, inclusion: { in: OWNER_TYPES }

  accepts_nested_attributes_for :boxes

  has_many_attached :files

  has_many :root_attachments,
           -> { where(box_id: nil) },
           as: :record,
           inverse_of: :record,
           dependent: :destroy,
           class_name: 'ActiveStorage::Attachment'

  # DEPRECATED BEGIN
  has_many :attachments,
           -> { order('attachments.created_at DESC') },
           as: :containable,
           dependent: :destroy,
           inverse_of: :containable

  has_many :media_files, through: :attachments
  accepts_nested_attributes_for :attachments, allow_destroy: true
  # DEPRECATED END

  def name
    return I18n.t('vaults.family.label', community: owner.name) if owner_type == 'Family'

    I18n.t('vaults.private.label')
  end

  def cover_url
    return owner.cover_image_url(size: :medium) if owner_type == 'Family'

    owner.avatar_url(size: :medium)
  end
end
