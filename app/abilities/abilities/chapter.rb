module Abilities
  module Chapter
    def default_chapter
      can [:update, :destroy], ::Chapter, { author_id: user.id }
    end

    def super_admin_chapter
      can :manage, ::Chapter
    end

    def showcase_chapter; end
  end
end
