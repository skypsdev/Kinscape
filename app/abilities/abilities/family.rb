module Abilities
  module Family
    def default_family
      can :create, ::Family
      can :read, ::Family, { kinships: { user_id: user.id } }
      can :read, ::Family, { id: all_families_ids }
      can :manage, ::Family, { id: admin_families_ids }
      can :manage, ::Family, {
        id: admin_families_ids.push(user.personal_family.id, user.private_family.id)
      }
      cannot :destroy, ::Family, { id: [user.personal_family.id, user.private_family.id] }
      cannot :ownership, ::Family
      can :ownership, ::Family, { admin_kinship: { user_id: user.id } }
    end

    def super_admin_family; end

    def showcase_family
      can :read, ::Family, { kinships: { user_id: user.id } }
      can :read, ::Family, { id: all_families_ids }
    end
  end
end
