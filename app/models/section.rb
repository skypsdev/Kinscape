# == Schema Information
#
# Table name: sections
#
#  id         :integer          not null, primary key
#  body       :text
#  story_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  media_type :string           not null
#  position   :integer          not null
#  author_id  :integer
#  title      :string
#  aws        :boolean
#

class Section < ApplicationRecord
  acts_as_list scope: :story, top_of_list: 0

  belongs_to :story, counter_cache: true, touch: true
  belongs_to :author, class_name: 'User'

  has_many :comments,
           -> { order(:created_at) },
           dependent: :destroy,
           as: :commentable,
           inverse_of: :commentable
  has_many :commenters, through: :comments, source: :user

  has_encrypted_rich_text :rich_body

  validates :story, presence: true

  after_commit :update_story_contributors!

  # DEPRECATED BEGIN
  has_many :attachments,
           -> { order(:position) },
           as: :containable,
           dependent: :destroy,
           inverse_of: :containable

  has_many :media_files, through: :attachments
  accepts_nested_attributes_for :attachments, allow_destroy: true
  # DEPRECATED END

  delegate :user, to: :story
  delegate :name, to: :author, prefix: true

  # Used for displaying the number of contributors to a story
  # TODO: Use counter_cache instead callback
  def update_story_contributors!
    story.update_column(:contributors_count, story.contributors.size) if story.persisted?
  end
end
