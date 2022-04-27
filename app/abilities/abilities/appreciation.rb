module Abilities
  module Appreciation
    def default_appreciation
      can :create, ::Appreciation, { commentable: { family_id: families_ids } }
      can :destroy, ::Appreciation, { user_id: user.id }
    end

    def super_admin_appreciation; end

    def showcase_appreciation; end
  end
end
