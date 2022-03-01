# == Schema Information
#
# Table name: kinships
#
#  id          :bigint           not null, primary key
#  user_id     :integer          not null
#  family_id   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  nickname    :string
#  location    :string
#  birth_date  :string
#  birth_place :string
#  address     :string
#  phone       :string
#  email       :string
#  death_date  :string
#

class KinshipSerializer < BaseSerializer
  set_type :kinship
  set_id :id

  attributes(
    :created_at,
    :user_id,
    :rich_profile,
    :avatar_url,
    :media_avatar,
    :nickname,
    :location,
    :birth_date,
    :birth_place,
    :address,
    :phone,
    :email,
    :death_date,
    :role,
    :profile_attrs,
    :description
  )

  belongs_to_encoded :family
  has_many :chapters

  attribute :family_id do |object|
    object.family.uid
  end

  attribute :links do |object|
    object.chapters.pluck(:id, :title, :position).map do |arr|
      { id: arr[0], title: arr[1], position: arr[2] }
    end
  end

  attribute :rich_profile do |object|
    object.rich_profile.attributes.merge(
      body: object.rich_profile.body.try(:to_trix_html),
      html: object.rich_profile.body.to_s
    )
  end

  attribute :name, &:nickname

  attribute :user_type do |object|
    # TODO-CONNECTOR: remove that attribute
    if object.user == object.family.admin
      'administrator'
    elsif object.user_id.nil?
      'offline member'
    else
      'default'
    end
  end

  attribute :user_title do |object|
    object.user&.title
  end

  attribute :invited_by do |object|
    object.inviter&.name
  end

  attribute :is_connected_by_current_user do |object|
    # TODO-CONNECTOR: remove that attribute
    object.user == object.family.admin
  end

  attribute :avatar_url do |object|
    object.avatar_url(size: :medium)
  end

  attribute :is_current_user_connector do |object, params|
    # TODO-CONNECTOR: remove that attribute
    params[:current_user].role_for(object.family) == 'admin'
  end
end
