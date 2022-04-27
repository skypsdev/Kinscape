module Api
  module V1
    class OwnershipTransfersController < BaseController
      def new
        response_service.render_collection(
          FamilySerializer,
          current_user.owned_families,
          options: { include: [:kinships], params: { ownership_transfer: true } }
        )
      end

      def create
        family = Family.find(params[:family_id])
        authorize! :ownership, family
        new_admin = User.find(params[:new_admin_id])
        ownership = OwnershipTransfer.create(
          family: family,
          new_admin: new_admin,
          old_admin: current_user,
          expires_at: Time.find_zone(params[:time_zone]).parse(params[:end_date]).utc
        )
        return response_service.render_error(ownership.errors.full_messages) if ownership.invalid?

        ::MailerService.call(:admin_transfer, params: { ownership_transfer: ownership })
        response_service.render_no_content
      end
    end
  end
end
