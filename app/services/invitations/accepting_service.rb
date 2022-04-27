module Invitations
  class AcceptingService < ApplicationService
    def initialize(invitation, params, current_user)
      @invitation = invitation
      @params = params
      @current_user = current_user
      @family = invitation.family
    end

    def call
      attach_recipient unless invitation.recipient
      raise CanCan::AccessDenied if invitation.recipient != current_user

      invitation.kinship ? update_kinship : build_kinship
      invitation.accepted_at = Time.current
      # TODO: Notify Personal Family members?
      if invitation.save! && family.default_access?
        ::Invitations::NotificationService.call(invitation.family, invitation.recipient)
      end
      invitation
    end

    private

    attr_reader :invitation, :params, :current_user, :family

    def attach_recipient
      user = User.find_by(email: invitation.email)
      invitation.recipient = user || current_user
    end

    def role
      family.personal_access? ? :guest : invitation.role
    end

    def build_kinship
      kinship_params = {
        kinships_attributes: [
          {
            **params,
            role: role,
            family_id: invitation.family_id,
            inviter_id: invitation.sender_id,
            access_type: family.access_type
          }
        ]
      }
      invitation.recipient.assign_attributes(kinship_params)
    end

    def update_kinship
      invitation.kinship.assign_attributes(
        **params,
        role: role,
        user_id: invitation.recipient_id,
        access_type: family.access_type
      )
    end
  end
end
