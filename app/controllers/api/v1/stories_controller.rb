module Api
  module V1
    class StoriesController < BaseController
      def create
        authorize! :create, Story
        story = ::Stories::CreationService.call(story_params, current_user)
        response_service.render(StorySerializer, story)
      end

      protected

      def story_params
        params.require(:story).permit(
          :cover,
          :title,
          :description,
          :start_year,
          :start_month,
          :start_day,
          :end_year,
          :end_month,
          :end_day,
          :is_range,
          categories: []
        )
      end
    end
  end
end
