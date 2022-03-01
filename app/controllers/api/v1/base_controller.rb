module Api
  module V1
    class BaseController < ActionController::API
      before_action do
        # host is required for rails_blob_url method
        ActiveStorage::Current.host = request.base_url if Rails.env.test?
      end
      include Clearance::Controller
      include Pagy::Backend

      before_action :authenticate_user
      after_action { pagy_headers_merge(@pagy) if @pagy }
      after_action { story_headers_merge(@story_headers) if @story_headers }
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from CanCan::AccessDenied, with: :render_unauthorized

      private

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

      def story_headers_merge(story_headers)
        response.headers['Unfiltered-Count'] = story_headers[:unfiltered_count]
        response.headers['All-Stories-Categories'] = story_headers[:all_categories]
      end
    end
  end
end
