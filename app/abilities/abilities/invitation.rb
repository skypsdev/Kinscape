module Abilities
  module Invitation
    def default_invitation
      can [:read, :update], ::Invitation, { recipient_id: nil }
      cannot [:read, :update], ::Invitation, { email: ::User.where.not(id: user.id).pluck(:email) } unless casl
      cannot [:read, :update], ::Invitation, { sender_id: user.id }

      can :resend, ::Invitation, { family_id: admin_families_ids }
      can :destroy, ::Invitation, { family_id: admin_families_ids }

      can :manage, ::Invitation, { recipient_id: user.id }
      can :manage, ::Invitation, { email: user.email }
    end

    def super_admin_invitation; end

    def showcase_invitation; end
  end
end
