class Comment < ApplicationRecord
  COMMENTABLE_TYPES = %w(Chapter Section Publication Comment).freeze
  TOP_COMMENTABLE_TYPES = %w(Family Publication Kinship).freeze

  default_scope { order(:created_at) }

  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :user
  belongs_to :top_commentable, polymorphic: true
  has_many :comments, dependent: :destroy, as: :commentable, inverse_of: :commentable

  validates :commentable_type, inclusion: { in: COMMENTABLE_TYPES }
  validates :top_commentable_type, inclusion: { in: TOP_COMMENTABLE_TYPES }
  validates :body, presence: true
  validates :commentable, presence: true
  validates :user, presence: true
  validates :top_commentable, presence: true
end
