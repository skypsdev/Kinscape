module Api
  module V1
    module Kinships
      class RolesController < BaseController
        def update
          kinship = Kinship.find(params[:kinship_id])
          authorize! :update, kinship
          return response_service.render_forbidden unless kinship_params[:role].in?(Kinship.roles.excluding('admin'))

          kinship.assign_attributes(kinship_params)
          ::MailerService.call(:role_change, params: { kinship: kinship }) if kinship.save
          response_service.render(KinshipSerializer, kinship)
        end

        private

        def kinship_params
          params.require(:kinship).permit(:role)
        end
      end
    end
  end
end
