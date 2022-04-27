class Section < ApplicationRecord
  include Showcase

  acts_as_list scope: :story, top_of_list: 0

  belongs_to :story, counter_cache: true, touch: true
  belongs_to :author, class_name: 'User'
  belongs_to :kinship, optional: true
  belongs_to :original_section, class_name: 'Section', optional: true

  has_many :publications, through: :story
  has_many :appreciations, as: :appreciable, dependent: :destroy
  has_many :comments,
           -> { order(:created_at) },
           dependent: :destroy,
           as: :commentable,
           inverse_of: :commentable
  has_many :commenters, through: :comments, source: :user

  has_encrypted_rich_text :rich_body

  validates :story, presence: true

  after_commit :update_story_contributors!

  delegate :user, to: :story
  delegate :name, to: :author, prefix: true

  # Used for displaying the number of contributors to a story
  def update_story_contributors!
    story.update_column(:contributors_count, story.contributors.size) if story.persisted?
  end
end
