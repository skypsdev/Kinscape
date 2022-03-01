module Api
  module V1
    module Kinships
      class InvitationsController < BaseController
        def create
          authorize! :manage, kinship
          return response_service.render_forbidden if kinship.user_id

          invitation = ::Invitations::OfflineMembers::SendingService.call(
            kinship: kinship,
            params: create_params,
            current_user: current_user
          )
          response_service.render(InvitationSerializer, invitation)
        end

        private

        def create_params
          params.require(:invitation).permit(:message, :email, :role, :user_id)
        end

        def kinship
          @kinship ||= Kinship.find(params[:kinship_id])
        end
      end
    end
  end
end
