module Abilities
  module ActiveAdmin
    def default_active_admin; end

    def super_admin_active_admin
      can :manage, ::ActiveAdmin::Page
    end

    def showcase_active_admin; end
  end
end
