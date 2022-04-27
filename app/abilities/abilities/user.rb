module Abilities
  module User
    def default_user
      can :manage, ::User, { id: user.id }
    end

    def super_admin_user
      can :manage, ::User
    end

    def showcase_user
      can :read, ::User, { id: user.id }
    end
  end
end
