module Api
  module V1
    class SectionsController < BaseController
      def index
        authorize! :read, story
        @pagy, sections = pagy(
          Section.includes(:rich_text_rich_body, author: :avatar, story: :families)
                 .references(:story)
                 .order(:position)
                 .with_rich_text_rich_body_and_embeds
                 .where(Story.arel_table[:id].eq(story.id)),
          items: params[:per_page] || 12
        )
        response_service.render_collection(SectionSerializer, sections)
      end

      def create
        authorize! :read, story
        section = ::Sections::CreationService.call(story, current_user, section_params)
        response_service.render(SectionSerializer, section)
      end

      def update
        authorize! :update, section
        section_updated = ::Sections::UpdatingService.call(section, current_user, section_params)
        response_service.render(SectionSerializer, section_updated)
      end

      def destroy
        authorize! :destroy, section
        section.destroy
        story.touch

        response_service.render_no_content
      end

      private

      def section_params
        params.permit(
          :media_type,
          :position,
          :title,
          rich_body: [:body]
        )
      end

      def story
        @story ||= Story.find_by_uid!(params[:story_id])
      end

      def section
        @section ||= story.sections.find(params[:id])
      end

      def mark_story_as_read
        @story.reload.mark_as_read! for: current_user
      end
    end
  end
end
