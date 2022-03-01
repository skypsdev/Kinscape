# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
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
#  storage_size       :bigint
#

class UserSerializer < BaseSerializer
  # include ActionView::Helpers::NumberHelper

  set_type :user
  set_id :id

  attributes(
    :name,
    :first_name,
    :last_name,
    :location,
    :email,
    :phone,
    :birth_date,
    # :subscription_trial_days,
    :admin
  )

  has_many_encoded :families
  has_many :kinships

  attribute :avatar_url do |object|
    object.avatar_url(size: :medium)
  end

  attribute :vault_id do |object|
    object.vault.id
  end

  attribute :guest, &:guest?

  attribute :trialing, &:trialing?

  attribute :active, &:active?

  attribute :abilities, if: proc { |_record, params| params&.dig(:abilities) } do |object|
    Ability.new(object, casl: true).to_list
  end
end
