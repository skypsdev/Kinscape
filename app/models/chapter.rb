class Chapter < ApplicationRecord
  include Showcase

  acts_as_list scope: :chapterable, top_of_list: 0

  belongs_to :chapterable, polymorphic: true
  belongs_to :author, class_name: 'User'
  belongs_to :kinship, optional: true

  has_many :appreciations, as: :appreciable, dependent: :destroy
  has_many :comments,
           -> { order(:created_at) },
           dependent: :destroy,
           as: :commentable,
           inverse_of: :commentable
  has_many :commenters, through: :comments, source: :user

  has_encrypted_rich_text :rich_body
end
