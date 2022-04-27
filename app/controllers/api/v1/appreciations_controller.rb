module Api
  module V1
    class AppreciationsController < BaseController
      def create
        authorize! :create, Appreciation
        appreciation = Appreciation::CreationService.call(current_user, appreciation_params, publication: publication)
        response_service.render(AppreciationSerializer, appreciation)
      end

      def destroy
        appreciation = Appreciation.find(params[:id])
        authorize! :destroy, appreciation
        appreciation.destroy

        response_service.render_no_content
      end

      private

      def publication
        return nil unless params[:publication_id]

        @publication ||= Publication.accessible_by(current_ability).find(params[:publication_id])
      end

      def appreciation_params
        params.require(:appreciation).permit(:reaction, :appreciable_type, :appreciable_id)
      end
    end
  end
end
