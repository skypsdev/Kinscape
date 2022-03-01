module Api
  module V1
    class InvitationsController < BaseController
      def show
        if invitation && current_user.families.include?(invitation.family)
          return render json: { message: I18n.t('invitations.flash.success.already_accepted') }, status: 403
        end

        authorize! :read, invitation
        response_service.render(InvitationSerializer, invitation, options: options)
      end

      def update
        authorize! :update, invitation
        updated_invitation = ::Invitations::AcceptingService.call(invitation, update_params, current_user)
        response_service.render(InvitationSerializer, updated_invitation, options: options)
      end

      def destroy
        invitations.all? { |invitation| authorize! :destroy, invitation }
        invitations.destroy_all
        response_service.render_no_content
      end

      private

      def options
        { include: [:family] }
      end

      def invitation
        @invitation ||= Invitation.find(params[:id])
      end

      def invitations
        @invitations ||= Invitation.where(id: params[:ids])
      end

      def update_params
        params.require(:invitation).permit(:nickname, :profile_attrs, :avatar)
      end
    end
  end
end
