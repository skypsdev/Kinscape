module Api
  module V1
    class BaseController < ActionController::API
      include Clearance::Controller
      include Pagy::Backend

      before_action :authenticate_user
      after_action { pagy_headers_merge(@pagy) if @pagy }
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from CanCan::AccessDenied, with: :render_unauthorized

      private

      def current_ability
        @current_ability ||= ::Ability.new(current_user, showcase: params[:showcase].present?)
      end

      def includes
        params[:include]&.split(',')
      end

      def response_service
        @response_service ||= Api::ResponseService.new(self, current_user)
      end

      def authenticate_user
        return if current_user

        render_unauthorized
      end

      def render_not_found
        response_service.render_not_found
      end

      def render_unauthorized
        response_service.render_unauthorized
      end
    end
  end
end
