module Api
  module V1
    module Families
      module Invitations
        class ResendsController < BaseController
          def create
            authorize! :manage, family
            invitations.each do |invitation|
              ::MailerService.call(:invitation, params: { invitation: invitation })
            end
            response_service.render_collection(InvitationSerializer, invitations)
          end

          private

          def invitations
            @invitations ||= family.invitations.where(id: params[:ids])
          end

          def family
            @family ||= Family.find_by_uid!(params[:family_id])
          end
        end
      end
    end
  end
end
