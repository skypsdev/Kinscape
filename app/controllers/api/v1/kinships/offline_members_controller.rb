module Api
  module V1
    module Kinships
      class OfflineMembersController < BaseController
        def update
          kinship = Kinship.find(params[:kinship_id])
          authorize! :update, kinship

          return response_service.render_error(I18n.t('offline_member.admin_error')) if kinship.role_admin?

          kinship = ::Kinships::ActiveToOfflineService.call(kinship)
          response_service.render(KinshipSerializer, kinship)
        end
      end
    end
  end
end
