module Api
  module V1
    module Kinships
      class RolesController < BaseController
        def update
          kinship = Kinship.find(params[:kinship_id])
          authorize! :update, kinship
          # TODO: add dry-validation gem?
          return response_service.render_forbidden unless kinship_params[:role].in?(Kinship.roles.excluding('admin'))

          kinship.update(kinship_params)
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
