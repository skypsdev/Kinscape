module Api
  module V1
    module Publications
      class AppreciationsController < BaseController
        def create
          authorize! :create, Appreciation
          appreciation = Appreciation::CreationService.call(current_user, publication, appreciation_params)
          response_service.render(AppreciationSerializer, appreciation)
        end

        def destroy
          appreciation = publication.appreciations.find(params[:id])
          authorize! :destroy, appreciation
          appreciation.destroy

          response_service.render_no_content
        end

        private

        def publication
          @publication ||= Publication.accessible_by(current_ability).find(params[:publication_id])
        end

        def appreciation_params
          params.require(:appreciation).permit(:reaction)
        end
      end
    end
  end
end
