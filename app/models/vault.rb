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

  def name
    return I18n.t('vaults.family.label', community: owner.name) if owner_type == 'Family'

    I18n.t('vaults.private.label')
  end

  def cover_url
    return owner.cover_image_url(size: :medium) if owner_type == 'Family'

    owner.personal_kinship.avatar_url(size: :medium)
  end
end
