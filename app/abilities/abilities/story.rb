module Abilities
  module Story
    def default_story
      can :create, ::Story
    end

    def super_admin_story; end

    def showcase_story; end
  end
end
