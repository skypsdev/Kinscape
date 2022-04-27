module Abilities
  module Vault
    def default_vault
      can :read, ::Vault, { owner_type: 'Family', owner_id: families_ids }
      can :add_boxes_to_vault, ::Vault, { owner_type: 'Family', owner_id: except_guested_ids }
      can :manage, ::Vault, { owner_type: 'Family', owner_id: admin_families_ids }
      can :manage, ::Vault, { owner_type: 'User', owner_id: user.id }
    end

    def super_admin_vault; end

    def showcase_vault
      can :read, ::Vault, { owner_type: 'User', owner_id: user.id }
      can :read, ::Vault, { owner_type: 'Family', owner_id: families_ids }
    end
  end
end
