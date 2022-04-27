class KinshipSerializer < BaseSerializer
  set_type :kinship
  set_id :id

  attributes(
    :created_at,
    :user_id,
    :family_id,
    :avatar_url,
    :nickname,
    :role,
    :profile_attrs,
    :description,
    personal: :personal_access?
  )

  belongs_to :family
  has_many :chapters
  has_many :all_comments, serializer: CommentSerializer

  attribute :links do |object|
    object.chapters.pluck(:id, :title, :position).map do |arr|
      { id: arr[0], title: arr[1], position: arr[2] }
    end
  end

  attribute :name, &:nickname

  attribute :invited_by do |object|
    object.family&.kinship_for(object.inviter)&.nickname if object.inviter
  end

  attribute :is_connected_by_current_user do |object|
    # TODO-CONNECTOR: remove that attribute
    object.id == object.family.admin_kinship.id
  end

  attribute :avatar_url do |object|
    object.avatar_url(size: :medium)
  end

  attribute :is_current_user_connector do |object, params|
    # TODO-CONNECTOR: remove that attribute
    object.user_id == params[:current_user].id && object.role == 'admin'
  end
end
