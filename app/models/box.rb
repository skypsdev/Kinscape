class Box < ApplicationRecord
  belongs_to :vault
  belongs_to :parent_box, class_name: 'Box', inverse_of: :child_boxes, optional: true

  with_options dependent: :destroy do
    has_many :child_boxes, class_name: 'Box', foreign_key: :parent_box_id, inverse_of: :parent_box
    has_many :attachments, class_name: 'ActiveStorage::Attachment'
  end

  validates :name, :vault, presence: true
  validates :name, uniqueness: { scope: [:vault, :parent_box] }, length: { maximum: 50 }
end
