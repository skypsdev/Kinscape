module Api
  module V1
    class OwnershipTransfersController < BaseController
      def new
        response_service.render_collection(
          FamilySerializer,
          current_user.families,
          options: { include: [:kinships] }
        )
      end

      def create
        family = current_user.families.find_by_uid(params[:family_id])
        new_admin = User.find(params[:new_admin_id])
        ownership = OwnershipTransfer.create(
          family: family,
          new_admin: new_admin,
          old_admin: current_user,
          expires_at: Time.find_zone(params[:timeZone]).parse(params[:endDate]).utc
        )
        return response_service.render_error(ownership.errors.full_messages) if ownership.invalid?

        ::MailerService.call(:transfer_confirmation, params: { ownership_transfer: ownership })
        response_service.render_no_content
      end
    end
  end
end
