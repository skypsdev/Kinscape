# == Schema Information
#
# Table name: appreciations
#
#  id               :bigint           not null, primary key
#  appreciable_type :string           not null
#  appreciable_id   :bigint           not null
#  user_id          :bigint           not null
#  reaction         :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Appreciation < ApplicationRecord
  enum reaction: { smile: 0 }
  belongs_to :appreciable, polymorphic: true, counter_cache: true
  belongs_to :user

  validates :reaction, presence: true
  validates :user_id, uniqueness: { scope: [:appreciable_id, :appreciable_type] }
end
