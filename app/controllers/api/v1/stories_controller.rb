require 'filestack_config'

module Api
  module V1
    class StoriesController < BaseController
      def chapter_links
        authorize! :read, story
        response_service.render(StorySerializer, story, options: { include: includes })
      end

      def create
        authorize! :create, Story
        story = ::Stories::CreationService.call(story_params, current_user)
        response_service.render(StorySerializer, story)
      end

      def update
        authorize! :update, story
        story_updated = ::Stories::UpdatingService.call(story, story_params)
        story_updated.mark_as_read! for: current_user
        response_service.render(StorySerializer, story_updated)
      end

      def destroy
        authorize! :destroy, story
        story.destroy!
        response_service.render_no_content
      end

      def duplicate
        authorize! :create, story
        duplicated_story = ::Stories::DuplicationService.call(story)
        duplicated_story.mark_as_read! for: current_user
        response_service.render(StorySerializer, duplicated_story)
      end

      def notify
        authorize! :read, story
        story.publications.not_private_type.each do |publication|
          ::Stories::NotificationService.notify_contribution(publication, current_user)
        end

        response_service.render(StorySerializer, story)
      end

      def upload_config
        # TODO: remove endpoint
        render json: FilestackConfig.upload
      end

      protected

      def story
        @story ||= Story.find_by_uid!(params[:id])
      end

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
