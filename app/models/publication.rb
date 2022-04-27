class Publication < ApplicationRecord
  include Showcase

  belongs_to :story
  belongs_to :family
  belongs_to :kinship
  has_many :shared_publications, through: :story, source: :not_private_publications

  has_one :user, through: :story

  with_options dependent: :destroy do
    has_many :appreciations, as: :appreciable
    has_many :all_comments, class_name: 'Comment', as: :top_commentable
  end
  has_many :commenters, through: :all_comments, source: :user

  validate :publishing_date, on: :create

  before_validation :fill_kinship

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
    private: 'private',
    personal: 'personal'
  }, _suffix: :type

  private

  def publishing_date
    return unless publish_on && publish_on < Time.zone.today

    errors.add(:base, :must_be_in_future)
  end

  def fill_kinship
    return if kinship_id

    self.kinship_id = family.kinship_for(story.user).id
  end
end
