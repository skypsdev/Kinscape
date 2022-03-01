# == Schema Information
#
# Table name: publications
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  family_id           :integer
#  story_id            :integer          not null
#  publish_on          :date
#  notified_at         :datetime
#  share_type          :string           default("community"), not null
#  comments_count      :integer          default(0), not null
#  appreciations_count :integer          default(0), not null
#

class Publication < ApplicationRecord
  belongs_to :family, optional: true
  belongs_to :story
  has_many :shared_publications, through: :story, source: :not_private_publications

  has_one :user, through: :story

  with_options dependent: :destroy do
    has_many :appreciations, as: :appreciable
    has_many :comments, -> { order(:created_at) }, as: :commentable, inverse_of: :commentable
    has_many :all_comments, class_name: 'Comment'
  end
  has_many :commenters, through: :comments, source: :user

  validate :publishing_date, on: :create

  scope :published, -> { where(publish_on: ..Time.zone.today).or(where(publish_on: nil)) }
  scope :time_capsules, -> {
    where(<<~SQL.squish)
      publish_on IS NOT NULL
      AND publish_on <= NOW()
      AND notified_at IS NULL
    SQL
  }

  enum share_type: {
    community: 'community',
    shared: 'shared',
    private: 'private'
  }, _suffix: :type

  def publishing_date
    return unless publish_on && publish_on < Time.zone.today

    errors.add(:base, :must_be_in_future)
  end
end
