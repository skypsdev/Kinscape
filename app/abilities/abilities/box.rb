module Abilities
  module Box
    def default_box
      can :read, ::Box, { vault: { owner_type: 'Family', owner_id: guested_families_ids } }
      can :manage, ::Box, { vault: { owner_type: 'Family', owner_id: except_guested_ids } }
      can :manage, ::Box, { vault: { owner_type: 'User', owner_id: user.id } }
    end

    def super_admin_box; end

    def showcase_box
      can :read, ::Box, { vault: { owner_type: 'User', owner_id: user.id } }
      can :read, ::Box, { vault: { owner_type: 'Family', owner_id: families_ids } }
    end
  end
end
