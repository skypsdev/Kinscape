# == Schema Information
#
# Table name: families
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  old_cover      :string           default(""), not null
#  cover_image_id :integer
#  motto          :text             default(""), not null
#

class FamilySerializer < BaseSerializer
  extend ActionView::Helpers::NumberHelper

  set_type :family
  set_id :uid

  attributes(
    :name,
    :motto,
    :family_type,
    :description,
    :created_at
  )

  has_many :kinships
  has_many :chapters

  attribute :users_ids do |object|
    object.users.ids
  end

  attribute :admin_avatar_url do |object|
    object.admin_kinship.avatar_url(size: :thumb)
  end

  attribute :cover_url do |object|
    object.cover_image_url(size: :medium)
  end

  attribute :vault_id do |object|
    object.vault&.id
  end

  attribute :links do |object|
    # TODO: Switch to raw title array
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
