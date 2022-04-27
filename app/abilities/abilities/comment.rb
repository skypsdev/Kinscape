module Abilities
  module Comment
    def default_comment
      can :create, ::Comment, { commentable: { family_id: families_ids } }
      can :manage, ::Comment, { user_id: user.id }
      can :destroy, ::Comment, { top_commentable: { family_id: admin_families_ids } }
    end

    def super_admin_comment; end

    def showcase_comment; end
  end
end
