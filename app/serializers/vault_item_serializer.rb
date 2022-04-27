class VaultItemSerializer < BaseSerializer
  extend ActionView::Helpers::NumberHelper

  set_id :id

  attributes(
    :created_at
  )

  attribute :user_id do |object|
    object.is_a?(Box) ? nil : object.user_id
  end

  attribute :family_id do |object|
    object.is_a?(Box) ? nil : object.family&.id
  end

  attribute :user_name do |object|
    if object.is_a?(Box) || object.user.nil?
      nil
    elsif object.family_id.present?
      object.user.all_kinships.find_by(family_id: object.family_id)&.nickname
    else
      object.user.name
    end
  end

  attribute :size do |object|
    object.is_a?(Box) ? 'mocked size MB' : number_to_human_size(object.byte_size)
  end

  attribute :name do |object|
    if object.is_a?(Box)
      object.name
    elsif object.title.present?
      "#{object.title}.#{object.filename.extension}"
    else
      object.filename
    end
  end

  attribute :item_type do |object|
    object.is_a?(Box) ? 'box' : 'file'
  end

  attribute :content_type do |object|
    object.is_a?(Box) ? nil : object.content_type
  end

  attribute :url do |object|
    object.is_a?(Box) ? nil : Rails.application.routes.url_helpers.rails_blob_url(object, only_path: true)
  end

  attribute :cover_url do |object|
    if object.is_a?(Box) || !object.representable?
      nil
    elsif object.image?
      Rails.application.routes.url_helpers.rails_representation_url(
        object.variant(resize_to_limit: IMAGE_SIZE[:medium]),
        only_path: true
      )
    end
  end

  attribute :parent_boxes do |object|
    if object.is_a?(ActiveStorage::Attachment) || object.parent_box_id.nil?
      []
    else
      Concern::Box.get_parents(object.parent_box)
    end
  end

  attribute :blob_signed_id do |object|
    if object.is_a?(ActiveStorage::Attachment)
      object.blob.signed_id
    end
  end
end
