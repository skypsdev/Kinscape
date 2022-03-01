# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  confirmation_token :string(128)
#  remember_token     :string(128)      not null
#  old_avatar         :string           default(""), not null
#  metadata           :hstore
#  tour_completed     :boolean
#  first_name         :string
#  last_name          :string
#  avatar_id          :integer
#  caretaker_id       :integer
#  title              :string
#  confirmed_at       :datetime
#  admin              :boolean          default(FALSE)
#  stripe_id          :string
#  storage_size       :bigint           default(0)
#  uuid               :bigint
#  ability_all        :boolean          default(TRUE), not null
#
require 'filestack_config'

class User < ApplicationRecord
  include Clearance::User

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
  before_destroy :check_if_admin
  # before_destroy :destroy_family_vaults

  has_one :active_subscription, -> { active }, class_name: 'Subscription', inverse_of: :user
  has_one :active_family_subscription, -> { active }, class_name: 'FamilySubscription', inverse_of: :user

  with_options dependent: :destroy do
    has_one :vault, as: :owner, inverse_of: :owner
    has_many :subscriptions
    has_many :family_subscriptions
    has_many :comments
    has_many :kinships, inverse_of: :user
    has_many :admin_kinships, -> { role_admin }, class_name: 'Kinship', inverse_of: :user
    has_many :stories
    has_many :invitations, foreign_key: :sender_id, inverse_of: :sender
    has_many :appreciations
  end
  has_many :families, through: :kinships
  has_many :owned_families, through: :admin_kinships, class_name: 'Family', source: :family
  has_many :family_vaults, through: :families, source: :vault, class_name: 'Vault'
  has_many :sections, through: :stories
  has_many :publications, through: :stories
  has_one_attached :zip_file

  belongs_to :avatar, optional: true
  accepts_nested_attributes_for :avatar, reject_if: :all_blank
  accepts_nested_attributes_for :kinships

  store_accessor :metadata, *METADATA_FIELDS

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, confirmation: true, unless: proc { |a| a.password.blank? }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :sorted_by_name, -> { order('last_name, first_name, email') }
  scope :admins, -> { where(admin: true) }

  delegate :can?, :cannot?, to: :ability
  delegate :trial_days, to: :active_subscription, prefix: :subscription, allow_nil: true
  delegate :trialing?, :active?, to: :active_subscription, allow_nil: true

  def role_for(family)
    return unless family

    kinships.find { |kinship| kinship.family_id == family.id }&.role
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def avatar_url(size: nil)
    return avatar.url if avatar.present? && size.nil?

    avatar.cdn_url(format: size) if avatar.present?
  end

  def draft_stories
    stories.draft
  end

  def media_uploads_count
    sections.where.not(media_type: 'text').count
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

  # def destroy_family_vaults
  #   Vault.where(owner_id: id, owner_type: 'User').destroy_all
  # end
end
