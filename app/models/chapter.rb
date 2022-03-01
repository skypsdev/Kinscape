# == Schema Information
#
# Table name: chapters
#
#  id               :bigint           not null, primary key
#  chapterable_id   :integer
#  chapterable_type :string
#  position         :integer
#  title            :string
#  body             :text
#  media_type       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Chapter < ApplicationRecord
  acts_as_list scope: :chapterable, top_of_list: 0
  belongs_to :chapterable, polymorphic: true
  belongs_to :author, class_name: 'User'
  has_encrypted_rich_text :rich_body

  # DEPRECATED BEGIN
  has_many :attachments,
           -> { order(:position) },
           as: :containable,
           dependent: :destroy,
           inverse_of: :containable

  has_many :media_files, through: :attachments
  accepts_nested_attributes_for :attachments, allow_destroy: true
  # DEPRECATED END
end
