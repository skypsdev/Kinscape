class Appreciation < ApplicationRecord
  APPRECIABLE_TYPES = %w(Chapter Section Publication).freeze
  enum reaction: { smile: 0 }
  belongs_to :appreciable, polymorphic: true, counter_cache: true
  belongs_to :user

  validates :reaction, presence: true
  validates :appreciable_type, inclusion: { in: APPRECIABLE_TYPES }
  validates :user_id, uniqueness: { scope: [:appreciable_id, :appreciable_type] }
end
