module Api
  module V1
    module Invitations
      class ResendsController < BaseController
        def create
          invitations.all? { |invitation| authorize! :resend, invitation }
          invitations.each do |invitation|
            ::MailerService.call(:invitation, params: { invitation: invitation })
          end
          response_service.render_collection(InvitationSerializer, invitations)
        end

        private

        def invitations
          @invitations ||= Invitation.where(id: params[:ids])
        end
      end
    end
  end
end
