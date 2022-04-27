class User < ApplicationRecord
  include Clearance::User
  include Showcase

  ONBOARDING_DEFAULT = {
    pending: true
  }.freeze

  METADATA_FIELDS = [
    :nickname,
    :location,
    :birth_date,
    :birth_place,
    :address,
    :phone,
    :contact_email,
    :lpage
  ].freeze

  acts_as_reader

  after_create :create_vault
  after_create :create_personal_family, :create_private_family
  before_destroy :check_if_admin
  before_destroy :destroy_personal_family

  has_one :active_subscription, -> { active }, class_name: 'Subscription', inverse_of: :user
  has_one :active_family_subscription, -> { active }, class_name: 'FamilySubscription', inverse_of: :user

  with_options dependent: :destroy do
    has_one :vault, as: :owner, inverse_of: :owner
    has_many :subscriptions
    has_many :family_subscriptions
    has_many :comments
    has_many :stories
    has_many :invitations, foreign_key: :sender_id, inverse_of: :sender
    has_many :received_invitations, foreign_key: :recipient_id, inverse_of: :recipient, class_name: 'Invitation'
    has_many :appreciations
    has_many :all_kinships,                                          class_name: 'Kinship', inverse_of: :user
    has_one :private_kinship, -> { private_access.role_admin },      class_name: 'Kinship', inverse_of: :user
    has_one :personal_kinship, -> { personal_access.role_admin },    class_name: 'Kinship', inverse_of: :user
    has_many :kinships, -> { default_access },                       class_name: 'Kinship', inverse_of: :user
    has_many :following_kinships, -> { personal_access.role_guest }, class_name: 'Kinship', inverse_of: :user
    has_many :admin_kinships, -> { default_access.role_admin },      class_name: 'Kinship', inverse_of: :user
  end
  has_many :all_families,       class_name: 'Family', source: :family, through: :all_kinships
  has_one :private_family,      class_name: 'Family', source: :family, through: :private_kinship
  has_one :personal_family,     class_name: 'Family', source: :family, through: :personal_kinship
  has_many :families,           class_name: 'Family', source: :family, through: :kinships
  has_many :following_families, class_name: 'Family', source: :family, through: :following_kinships
  has_many :owned_families,     class_name: 'Family', source: :family, through: :admin_kinships

  has_many :followers, -> { role_guest }, through: :personal_family,     class_name: 'Kinship', source: :kinships
  has_many :followings, -> { role_admin }, through: :following_families, class_name: 'Kinship', source: :kinships

  has_many :followers_families, class_name: 'Family', source: :family, through: :followers

  has_many :family_vaults, through: :families, source: :vault, class_name: 'Vault'
  has_many :sections, through: :stories
  has_many :publications, through: :stories
  has_one_attached :zip_file

  accepts_nested_attributes_for :kinships

  store_accessor :metadata, *METADATA_FIELDS

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, confirmation: true, unless: proc { |a| a.password.blank? }
  validates :terms_and_conditions, acceptance: true

  scope :sorted_by_name, -> { order('last_name, first_name, email') }
  scope :admins, -> { where(admin: true) }

  delegate :can?, :cannot?, to: :ability
  delegate :trial_days, to: :active_subscription, prefix: :subscription, allow_nil: true
  delegate :trialing?, :active?, to: :active_subscription, allow_nil: true

  enum registration_method: {
    direct: 'direct',
    offline: 'offline', # from invitation to take over offline profile
    member: 'member', # from invitation to join community
    follower: 'follower' # from invitation to follow someone's life stories
  }, _prefix: true

  def role_for(family)
    return unless family

    kinships.find { |kinship| kinship.family_id == family.id }&.role
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def confirm_email
    return if confirmed_at && confirmation_token.nil?

    update confirmed_at: Time.zone.now,
           confirmation_token: nil
  end

  def guest?
    return if active_subscription&.active?
    return unless active_subscription&.trial_past_due?

    true
  end

  def default_payment_method
    return unless stripe_id

    stripe_customer = Stripe::Customer.retrieve(stripe_id)

    stripe_customer.sources.data.find \
      { |s| s.id == stripe_customer.default_source }
  end

  private

  def check_if_admin
    return if admin_kinships.blank?

    raise 'You are admin in some families, first delete them or pass admin rights to another user'
  end

  def create_vault
    create_vault!
  end

  def create_personal_family
    Family.create(
      name: 'My Life Stories',
      family_type: 'Personal',
      access_type: 'personal',
      kinships_attributes: [{
        user_id: id,
        nickname: name,
        access_type: 'personal',
        role: :admin
      }]
    )
  end

  def create_private_family
    Family.create(
      name: 'Private Stories',
      family_type: 'Private',
      access_type: 'private',
      kinships_attributes: [{
        user_id: id,
        nickname: name,
        access_type: 'private',
        role: :admin
      }]
    )
  end

  def destroy_personal_family
    personal_family&.destroy
  end
end
