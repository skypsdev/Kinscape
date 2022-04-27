class UserSerializer < BaseSerializer
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
    :onboarding,
    :registration_method,
    :admin
  )

  has_many :families
  has_many :kinships

  attribute :vault_id do |object|
    object.vault.id
  end

  attribute :private_family_id do |object|
    object.private_family.id
  end

  attribute :personal_family_id do |object|
    object.personal_family.id
  end

  attribute :personal_private_families do |object|
    FamilySerializer.new(
      [object.private_family, object.personal_family],
      fields: { family: [:name, :cover_url] }
    ).to_hash[:data]
  end

  attribute :guest, &:guest?

  attribute :trialing, &:trialing?

  attribute :active, &:active?

  attribute :abilities, if: proc { |_record, params| params&.dig(:abilities) } do |object|
    Ability.new(object, casl: true).to_list
  end
end
