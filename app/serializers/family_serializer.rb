class FamilySerializer < BaseSerializer
  extend ActionView::Helpers::NumberHelper

  set_type :family

  attributes(
    :name,
    :motto,
    :family_type,
    :description,
    :created_at
  )

  has_many :kinships do |object, params|
    if params[:skip_current_user]
      object.kinships.where.not(user_id: params[:current_user].id)
    elsif params[:ownership_transfer]
      object.kinships.where(role: [:co_admin, :member])
    else
      object.kinships
    end
  end
  has_many :chapters
  has_many :all_comments, serializer: CommentSerializer

  attribute :user_role do |object, params|
    object.kinship_for(params[:current_user])&.role
  end

  attribute :users_ids do |object|
    object.users.ids
  end

  attribute :admin_avatar_url do |object|
    object.admin_kinship.avatar_url(size: :thumb)
  end

  attribute :cover_url do |object|
    if object.personal_access?
      object.admin_kinship.avatar_url(size: :medium)
    else
      object.cover_image_url(size: :medium)
    end
  end

  attribute :vault_id do |object|
    object.vault&.id
  end

  attribute :links do |object|
    object.chapters.pluck(:id, :title, :position).map do |arr|
      { id: arr[0], title: arr[1], position: arr[2] }
    end
  end

  attribute :is_connected_by_current_user do |object, params|
    # TODO-CONNECTOR: remove this attribute
    object.admin.id == params[:current_user].id
  end

  attribute :connector_id do |object|
    # TODO-CONNECTOR: remove this attribute
    object.admin.id
  end

  attribute :connector_name do |object|
    object.admin_kinship.nickname
  end
end
