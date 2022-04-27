module Abilities
  module Kinship
    def default_kinship
      can :read, ::Kinship, { role: :admin, access_type: :personal, family_id: following_families_ids }
      cannot :read, ::Kinship, { role: :guest, access_type: [:personal, :private] }
      can :read, ::Kinship, { family_id: families_ids, access_type: :default }

      can :manage, ::Kinship, { family_id: admin_families_ids, user_id: nil, access_type: :default } # Offline Member
      can [:destroy, :update], ::Kinship, { family_id: admin_families_ids }
      can :destroy, ::Kinship, { family_id: user.personal_family.id }
      can :manage, ::Kinship, { user_id: user.id }
      cannot :destroy, ::Kinship, { role: :admin }
      cannot :destroy, ::Kinship, {
        user_id: user.id,
        family_id: [user.personal_family.id, user.private_family.id]
      }
    end

    def super_admin_kinship
      can :manage, ::Kinship
    end

    def showcase_kinship
      can :read, ::Kinship, { role: :admin, access_type: :personal, family_id: following_families_ids }
      cannot :read, ::Kinship, { role: :guest, access_type: [:personal, :private] }
      can :read, ::Kinship, { family_id: families_ids, access_type: :default }
      can :read, ::Kinship, { user_id: user.id }
    end
  end
end
