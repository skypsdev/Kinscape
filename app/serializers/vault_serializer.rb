class VaultSerializer < BaseSerializer
  set_id :id

  attribute :name do |object|
    if object.owner_type == 'User'
      I18n.t('vaults.private.label')
    else
      I18n.t('vaults.family.label', { community: object.owner.name })
    end
  end

  attribute :avatar_url do |object|
    if object.owner_type == 'User'
      kinships = object.owner.kinships.left_joins(:avatar_attachment)
      kinship_with_avatar = kinships.having('COUNT(active_storage_attachments) != 0').group(:id).limit(1).first
      kinship_with_avatar&.avatar_url(size: :medium)
    else
      object.owner.cover_image_url(size: :medium)
    end
  end
end
