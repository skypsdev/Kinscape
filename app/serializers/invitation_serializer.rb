# == Schema Information
#
# Table name: invitations
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  family_id    :integer          not null
#  sender_id    :integer          not null
#  recipient_id :integer
#  email        :string           not null
#  accepted_at  :datetime
#  message      :text             default(""), not null
#  first_name   :string
#  last_name    :string
#

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
    :role
  )

  attribute :newcomer do |object|
    object.recipient&.kinships.blank?
  end

  attribute :family_id do |object|
    object.family.uid
  end

  attribute :family_name do |object|
    object.family.name
  end

  attribute :family_cover_url do |object|
    object.family.cover_image_url(size: :medium)
  end

  attribute :sender_name do |object|
    object.family.kinship_for(object.sender).nickname
  end

  belongs_to_encoded :family
end
