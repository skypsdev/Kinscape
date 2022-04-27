module Api
  module V1
    module Families
      class InvitationsController < BaseController
        def index
          authorize! :read, family
          invitations = family.invitations.pending.order(:created_at)
          @pagy, records = pagy(invitations, items: 12)
          options = { include: [:family] }
          response_service.render_collection(InvitationSerializer, records, options: options)
        end

        def create
          authorize! :manage, family
          emails = create_params[:users].map do |user_params|
            ::Invitations::CreationService.call(
              family: family,
              user_params: user_params,
              current_user: current_user,
              message: create_params[:message]
            )
          end
          render json: {
            valid: emails.filter_map { |i| i[:valid] },
            invalid: emails.filter_map { |i| i[:invalid] },
            existing: emails.filter_map { |i| i[:existing] }
          }
        end

        private

        def create_params
          params.require(:invitation).permit(:message, users: [:email, :id, :role])
        end

        def family
          @family ||= if params[:showcase].present?
                        User.find_by(email: Showcase::USER_EMAIL).personal_family
                      else
                        Family.find(params[:family_id])
                      end
        end
      end
    end
  end
end
