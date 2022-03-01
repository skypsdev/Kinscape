module Invitations
  class AcceptingService < ApplicationService
    def initialize(invitation, params, current_user)
      @invitation = invitation
      @params = params
      @current_user = current_user
    end

    def call
      attach_recipient unless invitation.recipient
      raise CanCan::AccessDenied if invitation.recipient != current_user

      invitation.kinship ? update_kinship : build_kinship
      invitation.accepted_at = Time.current

      ::Invitations::NotifyAllMembers.call(invitation.family, invitation.recipient) if invitation.save!
      invitation
    end

    private

    attr_reader :invitation, :params, :current_user

    def attach_recipient
      user = User.find_by(email: invitation.email)
      invitation.recipient = user || current_user
    end

    def build_kinship
      kinship_params = {
        kinships_attributes: [
          {
            **params,
            role: invitation.role,
            family_id: invitation.family_id,
            inviter_id: invitation.sender_id
          }
        ]
      }
      invitation.recipient.assign_attributes(kinship_params)
    end

    def update_kinship
      invitation.kinship.assign_attributes(
        **params,
        role: invitation.role,
        user_id: invitation.recipient_id
      )
    end
  end
end
