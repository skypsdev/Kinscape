module Abilities
  module Attachment
    def default_attachment
      can :read, ::ActiveStorage::Attachment, { family_id: families_ids } if families_ids.present?
      can :manage, ::ActiveStorage::Attachment, { family_id: admin_families_ids } if admin_families_ids.present?
      can :manage, ::ActiveStorage::Attachment, { user_id: user.id }
    end

    def super_admin_attachment; end

    def showcase_attachment
      can :read, ::ActiveStorage::Attachment, { family_id: families_ids }
      can :read, ::ActiveStorage::Attachment, { user_id: user.id }
    end
  end
end
