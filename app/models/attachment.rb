# == Schema Information
#
# Table name: attachments
#
#  id               :integer          not null, primary key
#  media_file_id    :integer          not null
#  containable_id   :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  containable_type :string           not null
#  position         :integer
#  comments_count   :integer
#  box_id           :integer
#  uuid             :bigint
#

class Attachment < ApplicationRecord
  belongs_to :containable, polymorphic: true, optional: true
  belongs_to :media_file, touch: true
  belongs_to :box, optional: true

  has_many :comments,
           -> { order(:created_at) },
           dependent: :destroy,
           as: :commentable,
           inverse_of: :commentable

  accepts_nested_attributes_for :media_file, allow_destroy: true

  delegate :user, to: :containable
  delegate :story, to: :containable

  validates :media_file, presence: true
end
