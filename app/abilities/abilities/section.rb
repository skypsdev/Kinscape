module Abilities
  module Section
    def default_section
      can [:update, :destroy], ::Section, { author_id: user.id }
      can :destroy, ::Section, { story: { publications: { family_id: admin_families_ids, share_type: 'community' } } }
    end

    def super_admin_section
      can :manage, ::Section
    end

    def showcase_section; end
  end
end
