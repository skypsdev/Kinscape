# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text             not null
#  commentable_type :string           not null
#  commentable_id   :integer          not null
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  uuid             :bigint
#

class Comment < ApplicationRecord
  COMMENTABLE_TYPES = %w(Section Publication Comment).freeze
  include Uid

  default_scope { order(:created_at) }

  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :user
  belongs_to :publication, counter_cache: :all_comments_count

  has_many :comments,
           -> { order(:created_at) },
           dependent: :destroy,
           as: :commentable,
           inverse_of: :commentable

  validates :commentable_type, inclusion: { in: COMMENTABLE_TYPES }
  validates :body, presence: true
  validates :commentable, presence: true
  validates :user, presence: true
  validates :publication, presence: true # TODO: clean up database and add `null: false` on db level
end
