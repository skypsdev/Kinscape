class InvitationSerializer < BaseSerializer
  set_type :invitation
  set_id :id

  attributes(
    :created_at,
    :sender_id,
    :recipient_id,
    :email,
    :accepted_at,
    :message,
    :role,
    :family_id
  )

  belongs_to :family

  attribute :personal do |object|
    object.family.personal_access?
  end

  attribute :family_name do |object|
    object.family.name
  end

  attribute :family_type do |object|
    object.family.family_type
  end

  attribute :family_cover_url do |object|
    if object.family.personal_access?
      object.family.admin_kinship.avatar_url(size: :medium)
    else
      object.family.cover_image_url(size: :medium)
    end
  end

  attribute :sender_name do |object|
    object.family.kinship_for(object.sender).nickname
  end

  attribute :sender_kinship_id do |object|
    object.family.kinship_for(object.sender).id
  end
end
