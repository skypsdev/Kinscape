module Api
  module V1
    class ReceivedInvitationsController < BaseController
      def index
        response_service.render_collection(InvitationSerializer, invitations)
      end

      private

      def invitations
        @invitations ||= if params[:showcase].present?
                           User.find_by(email: Showcase::USER_EMAIL).received_invitations.pending
                         else
                           current_user.received_invitations.pending
                         end
      end
    end
  end
end
